# encoding: utf-8

require_relative "../spec_helper"
require "isodoc"

RSpec.describe Relaton::Render do
  let(:input) do
    <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <uri>https://eprints.soton.ac.uk/338791/</uri>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>Ramsey</surname>
              <formatted-initials>J. K.</formatted-initials>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>McGrew</surname>
              <formatted-initials>W. C.</formatted-initials>
            </name>
          </person>
        </contributor>
        <relation type="includedIn">
          <bibitem>
            <title>The nature of play: Great apes and humans</title>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Pellegrini</surname>
                  <forename initial="A">Anthony</forename>
                  <forename initial="D"/>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename initial="P">Peter</forename>
                  <forename initial="K">Kenneth</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
        <extent>
         <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
  end

  it "renders incollection, two authors, with Arabic i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. و W. C. MCGREW. Object play in great apes: Studies in nature and captivity. في: PELLEGRINI, Anthony D. و Peter Kenneth SMITH (محرران): «The nature of play: Great apes and humans» [electronic resource, 8vo]. الطبعة؜ 3. New York, NY: Guilford Press. 2005. ؜89–112 ص؜. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [ينظر: 3 سبتمبر 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "ar")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with German i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. und W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. und Peter Kenneth SMITH (Hrsg.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3 Ausg. New York, NY: Guilford Press. 2005. S. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [angesehen: 3. September 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with German internationalisation, with customisation of i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. and W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. and Peter Kenneth SMITH (Hrsg.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3 Ausg. New York, NY: Guilford Press. 2005. S. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [angesehen: 3. September 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de",
                                     i18nhash: { "author_and" => "and" })
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Spanish i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. y W. C. MCGREW. Object play in great apes: Studies in nature and captivity. En: PELLEGRINI, Anthony D. y Peter Kenneth SMITH (eds.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3.ª ed. New York, NY: Guilford Press. 2005. págs. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [visto: 3 de septiembre de 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "es")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with French i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. et W. C. MCGREW. Object play in great apes: Studies in nature and captivity. Dans : PELLEGRINI, Anthony D. et Peter Kenneth SMITH (éd.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3e édition. New York, NY : Guilford Press. 2005. p. 89–112. <link target="https://eprints.soton.ac.uk/338791/">https://eprints.soton.ac.uk/338791/</link>. [vu : 3 septembre 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "fr")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Russian i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. и W. C. MCGREW. Object play in great apes: Studies in nature and captivity. В: PELLEGRINI, Anthony D. и Peter Kenneth SMITH (изд.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. Третье издание. New York, NY: Guilford Press. 2005. стр. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [просмотрено: 3 сентября 2019 г.].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "ru")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Traditional Chinese i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY， J. K. 與 W. C. MCGREW。〈Object play in great apes: Studies in nature and captivity〉。在： PELLEGRINI， Anthony D. 與 Peter Kenneth SMITH （編輯）： <underline style="wavy">The nature of play: Great apes and humans</underline> ［electronic resource，8vo］。第第3版。 New York， NY： Guilford Press。2005。第89〜112頁。 <link target="https://eprints.soton.ac.uk/338791/">https://eprints.soton.ac.uk/338791/</link>。［閱：2019年9月3日］。</formattedref>
    OUTPUT
    i = IsoDoc::PresentationXMLConvert.new(language: "zh", script: "Hant")
    i.i18n_init("zh", "Hant", nil)
    p = Relaton::Render::General.new(language: "zh", script: "Hant",
                                     i18nhash: i.i18n.get)
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Simplified Chinese i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY，J. K.和W. C. MCGREW。〈Object play in great apes: Studies in nature and captivity〉。在：PELLEGRINI，Anthony D.和Peter Kenneth SMITH （编）：《The nature of play: Great apes and humans》［electronic resource，8vo］。第第三版。New York，NY：Guilford Press。2005。第89〜112页。<link target="https://eprints.soton.ac.uk/338791/">https://eprints.soton.ac.uk/338791/</link>。［阅：2019年9月3日］。</formattedref>
    OUTPUT
    i = IsoDoc::PresentationXMLConvert.new(language: "zh", script: "Hans")
    i.i18n_init("zh", "Hans", nil)
    p = Relaton::Render::General.new(language: "zh", script: "Hans",
                                     i18nhash: i.i18n.get)
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Japanese i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY、 J. K.、 W. C. MCGREW。 Object play in great apes: Studies in nature and captivity。 PELLEGRINI、 Anthony D.、 Peter Kenneth SMITH （編）： The nature of play: Great apes and humans ［electronic resource、 8vo］。第3版。 New York、 NY： Guilford Press。 2005。 89〜112頁。 <link target="https://eprints.soton.ac.uk/338791/">https://eprints.soton.ac.uk/338791/</link>。［参照： 2019年9月3日］。</formattedref>
    OUTPUT
    i = IsoDoc::PresentationXMLConvert.new(language: "ja", script: "Jpan")
    i.i18n_init("ja", "Jpan", nil)
    p = Relaton::Render::General.new(language: "ja", i18nhash: i.i18n.get)
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders cardinal editions" do
    input1 = input
      .sub("<edition>3</edition>", "<edition>3.0</edition>")
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. and W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. and Peter Kenneth SMITH (eds.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. Edition 3.0. New York, NY: Guilford Press. 2005. pp. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [viewed: September 3, 2019].</formattedref>
    OUTPUT
    i = IsoDoc::PresentationXMLConvert.new(language: "en", script: "Latn")
    i.i18n_init("en", "Latn", nil)
    p = Relaton::Render::General.new(language: "en", i18nhash: i.i18n.get)
    expect(HTMLEntities.new.decode(p.render(input1)))
      .to be_equivalent_to output

    output = <<~OUTPUT
      <formattedref>RAMSEY、 J. K.、 W. C. MCGREW。 Object play in great apes: Studies in nature and captivity。 PELLEGRINI、 Anthony D.、 Peter Kenneth SMITH （編）： The nature of play: Great apes and humans ［electronic resource、 8vo］。第3.0版。 New York、 NY： Guilford Press。 2005。 89〜112頁。 <link target="https://eprints.soton.ac.uk/338791/">https://eprints.soton.ac.uk/338791/</link>。［参照： 2019年9月3日］。</formattedref>
    OUTPUT
    i = IsoDoc::PresentationXMLConvert.new(language: "ja", script: "Jpan")
    i.i18n_init("ja", "Jpan", nil)
    p = Relaton::Render::General.new(language: "ja", i18nhash: i.i18n.get)
    expect(HTMLEntities.new.decode(p.render(input1)))
      .to be_equivalent_to output
  end

  it "processes status" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <edition>1</edition>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <status>
            <stage>valid</stage>
            </status>
            <place>Cambridge, UK</place>
      </bibitem>
    INPUT
    template = <<~TEMPLATE
      {{ status }}
    TEMPLATE
    output = "<formattedref>Valid</formattedref>"
    p = Relaton::Render::General
      .new(template: { book: template })
    expect(p.render(input, terminator: false))
      .to be_equivalent_to output
    output = "<formattedref>有効です</formattedref>"
    p = Relaton::Render::General
      .new(language: "ja", template: { book: template })
    expect(p.render(input, terminator: false))
      .to be_equivalent_to output
  end

  it "selects between two different i18n" do
    input = <<~INPUT
      <references>
        <bibitem type="book" id="A">
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
          <docidentifier type="ISBN">9781108877831</docidentifier>
          <date type="published"><on>2022</on></date>
                    <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
                  <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Anderson</surname><forename>David</forename></name>
            </person>
          </contributor>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Hering</surname><forename>Milena</forename></name>
            </person>
          </contributor>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
            </person>
          </contributor>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Payne</surname><forename>Sam</forename></name>
            </person>
          </contributor>
          <language>en</language>
          <script>Latn</script>
          <edition>1</edition>
          <series>
          <title>London Mathematical Society Lecture Note Series</title>
          <number>472</number>
          </series>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place>Cambridge, UK</place>
            <size><value type="volume">1</value></size>
        </bibitem>
        <bibitem type="book" id="B">
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
          <docidentifier type="ISBN">9781108877831</docidentifier>
          <date type="published"><on>2022</on></date>
          <language>ja</language>
          <script>Jpan</script>
                    <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
                  <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Anderson</surname><forename>David</forename></name>
            </person>
          </contributor>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Hering</surname><forename>Milena</forename></name>
            </person>
          </contributor>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
            </person>
          </contributor>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Payne</surname><forename>Sam</forename></name>
            </person>
          </contributor>
          <edition>1</edition>
          <series>
          <title>London Mathematical Society Lecture Note Series</title>
          <number>472</number>
          </series>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place>Cambridge, UK</place>
            <size><value type="volume">1</value></size>
        </bibitem>
        </references>
    INPUT
    output = {
      "A" =>
      "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
      "B" =>
        "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ, Sam PAYNE (編) — Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday — 第1版 — (London Mathematical Society Lecture Note Series 472 —) Cambridge, UK: Cambridge University Press — 2022 — DOI: https://doi.org/10.1017/9781108877831 — ISBN: 9781108877831 — 巻1。",
    }
    en = IsoDoc::PresentationXMLConvert.new(language: "en", script: "Latn")
    en.i18n_init("en", "Latn", nil)
    ja = IsoDoc::PresentationXMLConvert.new(language: "ja", script: "Jpan")
    ja.i18n_init("ja", "Jpan", nil)
    orig_en = Relaton::Render::General.new(language: "en")
    orig_en_i18n = orig_en.i18n.config[""].get
    en.i18n.merge(orig_en_i18n)
    orig_ja = Relaton::Render::General.new(language: "ja")
    orig_ja_i18n = orig_ja.i18n.config[""].get
    orig_ja_i18n["punct"]["biblio-field-delimiter"] = " — "
    ja.i18n.merge(orig_ja_i18n)
    mock_i18n_selector
    p = Relaton::Render::General.new(language: "ja",
                                     i18n_multi: {
                                       en: en.i18n, ja: ja.i18n
                                     })
    expect(p.render_all(input, type: "author-date")
      .transform_values { |v| v[:formattedref] })
      .to match_hash_pp output
  end

  private

  def mock_i18n_selector
    allow_any_instance_of(Relaton::Render::I18n)
      .to receive(:select_default) do |i18n_instance|
      i18n_instance.instance_variable_get(:@i18n)["en"]
    end

    allow_any_instance_of(Relaton::Render::I18n)
      .to receive(:select_obj) do |i18n_instance, obj|
      i18n_hash = i18n_instance.instance_variable_get(:@i18n)
      if obj[:language] == "ja"
        i18n_hash["ja"]
      else
        i18n_hash["en"]
      end
    end
  end
end
