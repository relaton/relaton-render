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
end
