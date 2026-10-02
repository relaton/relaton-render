# frozen_string_literal: true

require_relative "spec_helper"
require "relaton/bib"

# relaton-render#90: isodoc main's render-isodoc subclasses
# Relaton::Render::General (`class General < ::Relaton::Render::General`)
# and constructs it with the v1 option set (language:, script:, i18nhash:,
# config:). The constant must exist and boot; rendering delegates to the
# v2 engine; the retired liquid config warns once.
RSpec.describe Relaton::Render::General do
  let(:item) do
    Relaton::Bib::Bibitem.from_xml(<<~X)
      <bibitem type="book">
        <title>Eric, or Little by Little</title>
        <date type="published"><on>1971</on></date>
        <contributor><role type="author"/>
          <person><name><surname>Farrar</surname><forename>Frederic</forename></name></person>
        </contributor>
      </bibitem>
    X
  end

  it "accepts the v1 option set and renders through the v2 engine" do
    renderer = described_class.new(
      language: "en", script: "Latn", i18nhash: {}, config: nil,
    )
    expect(renderer.render(item))
      .to eq "FARRAR, Frederic. _Eric, or Little by Little_. 1971."
    expect(renderer.citation(item)).to eq "FARRAR, 1971"
  end

  it "applies a runtime i18n hash to the language pack" do
    renderer = described_class.new(
      language: "en", script: "Latn",
      i18nhash: { "and" => "und", "edition" => "Aufl." },
    )
    two_authors = Relaton::Bib::Bibitem.from_xml(<<~X)
      <bibitem type="book">
        <title>Two authors</title>
        <date type="published"><on>2000</on></date>
        <contributor><role type="author"/>
          <person><name><surname>One</surname></name></person>
        </contributor>
        <contributor><role type="author"/>
          <person><name><surname>Two</surname></name></person>
        </contributor>
      </bibitem>
    X
    expect(renderer.render(two_authors)).to include "ONE und TWO"
  end

  it "warns exactly once that the liquid config is retired" do
    expect do
      described_class.new(language: "en", config: { "template" => {} })
      described_class.new(language: "en", config: { "template" => {} })
    end.to output(/compatibility facade.*retired and ignored/m).to_stderr
  end

  describe "#render_all — isodoc's references rendering entry" do
    it "keys renderings by bibitem id with formattedref and citations" do
      renderer = described_class.new(language: "en", script: "Latn")
      renderings = renderer.render_all(<<~X)
        <references>
          <bibitem id="f1" type="book">
            <title>Eric, or Little by Little</title>
            <date type="published"><on>1971</on></date>
            <contributor><role type="author"/>
              <person><name><surname>Farrar</surname><forename>Frederic</forename></name></person>
            </contributor>
          </bibitem>
        </references>
      X
      expect(renderings["f1"][:formattedref])
        .to eq "FARRAR, Frederic. _Eric, or Little by Little_. 1971."
      expect(renderings["f1"][:citation][:short]).to eq "FARRAR, 1971"
    end

    it "returns nil for input without bibitems, as 1.x did" do
      expect(described_class.new(language: "en").render_all("<other/>")).to be_nil
    end
  end

  describe "#parse — isodoc's pref_ref_code entry" do
    it "extracts the authoritative identifiers from a bibitem node" do
      renderer = described_class.new(language: "en")
      doc = Nokogiri::XML(<<~X).root
        <bibitem id="x" type="standard">
          <docidentifier type="ISO" primary="true">ISO 19115-1:2014</docidentifier>
          <docidentifier type="urn">urn:iso:std:iso:19115:-1:ed-1:en</docidentifier>
        </bibitem>
      X
      data, = renderer.parse(doc)
      expect(data[:authoritative_identifier])
        .to eq ["ISO 19115-1:2014", "urn:iso:std:iso:19115:-1:ed-1:en"]
    end
  end

  describe "#citetemplate — standoc's eref style vocabulary" do
    it "exposes the 1.x style names as template_raw keys" do
      keys = described_class.new(language: "en").citetemplate.template_raw.keys
      expect(keys).to include(:author_date, :author, :short, :reference_tag)
    end
  end
end
