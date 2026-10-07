# frozen_string_literal: true

require "spec_helper"
require "relaton/bib"

# The canonical packs' conformance corpora: each pack pins the rendering
# of the shapes its owning manual declares. A failing example is the
# engine's or the pack's to fix - never the expectation's.
RSpec.describe "canonical style packs" do
  def render_item(style, xml, lang: "en")
    model = Relaton::Bib::Item.from_xml(xml)
    Relaton::Render::Iso690::Renderer.render(model, style: style, lang: lang)
  end

  def bib(xml)
    Relaton::Bib::Item.from_xml(xml)
  end

  # IEEE-SA Standards Style Manual 17.2: a standard's entry is its
  # designation and title, nothing else
  it "ieee-sa renders the designation-only standard form" do
    expect(render_item("ieee-sa", <<~XML)).to eq "ASME BPVC-I-2004, Boiler and Pressure Vessel Code"
      <bibitem type="standard" xmlns="http://riboseinc.com/isoxml">
        <title type="main">Boiler and Pressure Vessel Code</title>
        <docidentifier type="ASME">ASME BPVC-I-2004</docidentifier>
        <contributor><role type="publisher"/><organization><name>American Society of Mechanical Engineers</name></organization></contributor>
      </bibitem>
    XML
  end

  # 17.4: only the first book author inverts
  it "ieee-sa renders the first-name-inverted book form" do
    expect(render_item("ieee-sa", <<~XML)).to eq "Peck, R. B., W. E. Hanson, and T. H. Thornburn, <em>Foundation Engineering</em>, 2nd ed. New York: McGraw-Hill, 1972, pp. 230\u2013292."
      <bibitem type="book" xmlns="http://riboseinc.com/isoxml">
        <title type="main">Foundation Engineering</title>
        <contributor><role type="author"/><person><name><surname>Peck</surname><formatted-initials>R. B.</formatted-initials></name></person></contributor>
        <contributor><role type="author"/><person><name><formatted-initials>W. E.</formatted-initials><surname>Hanson</surname></name></person></contributor>
        <contributor><role type="author"/><person><name><formatted-initials>T. H.</formatted-initials><surname>Thornburn</surname></name></person></contributor>
        <edition>2</edition>
        <place><formattedPlace>New York</formattedPlace></place>
        <contributor><role type="publisher"/><organization><name>McGraw-Hill</name></organization></contributor>
        <date type="published"><on>1972</on></date>
        <extent><locality type="page"><referenceFrom>230</referenceFrom><referenceTo>292</referenceTo></locality></extent>
      </bibitem>
    XML
  end

  # LNCS: the creator list closes on a colon, the year closes the entry
  # in parentheses
  it "lncs renders the book form" do
    expect(render_item("lncs", <<~XML)).to eq "Knuth, D.E.: The TeXbook. Addison-Wesley, Reading (1984)"
      <bibitem type="book" xmlns="http://riboseinc.com/isoxml">
        <title type="main">The TeXbook</title>
        <contributor><role type="author"/><person><name><surname>Knuth</surname><formatted-initials>D. E.</formatted-initials></name></person></contributor>
        <contributor><role type="publisher"/><organization><name>Addison-Wesley</name></organization></contributor>
        <place><formattedPlace>Reading</formattedPlace></place>
        <date type="published"><on>1984</on></date>
      </bibitem>
    XML
  end

  # Chicago 17: only the first name inverts; production runs
  # "Place: Publisher"
  it "chicago renders the book form" do
    expect(render_item("chicago", <<~XML)).to eq "Gladwell, Malcolm. <em>Blink: The Power of Thinking Without Thinking</em>. New York: Little, Brown, 2005."
      <bibitem type="book" xmlns="http://riboseinc.com/isoxml">
        <title type="main">Blink: The Power of Thinking Without Thinking</title>
        <contributor><role type="author"/><person><name><forename>Malcolm</forename><surname>Gladwell</surname></name></person></contributor>
        <contributor><role type="publisher"/><organization><name>Little, Brown</name></organization></contributor>
        <place><formattedPlace>New York</formattedPlace></place>
        <date type="published"><on>2005</on></date>
      </bibitem>
    XML
  end

  # APA 7: all names invert with initials, the date follows the authors
  # in parentheses, book titles italic, no place of publication
  it "apa renders the book form" do
    expect(render_item("apa", <<~XML)).to eq "Gladwell, M. (2005). <em>Blink: The Power of Thinking Without Thinking</em>. Little, Brown."
      <bibitem type="book" xmlns="http://riboseinc.com/isoxml">
        <title type="main">Blink: The Power of Thinking Without Thinking</title>
        <contributor><role type="author"/><person><name><forename>Malcolm</forename><surname>Gladwell</surname></name></person></contributor>
        <contributor><role type="publisher"/><organization><name>Little, Brown</name></organization></contributor>
        <date type="published"><on>2005</on></date>
      </bibitem>
    XML
  end
end
