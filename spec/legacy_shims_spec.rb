# frozen_string_literal: true

require_relative "spec_helper"
require "relaton/bib"

# The deprecated 1.x leaves, restored so flavor gems that subclass them
# load against this line. Superseded by the Iso690 engine.
RSpec.describe "Relaton::Render 1.x legacy leaves" do
  it "exposes the subclassable constants on demand" do
    %i[Parse Fields Date Template Citations].each do |name|
      expect(Relaton::Render.const_defined?(name)).to be true
    end
  end

  it "parses a relaton model through the legacy Parse" do
    parser = Relaton::Render::Parse.new(lang: "en")
    doc = Relaton::Bib::Bibitem.from_xml(<<~XML)
      <bibitem type="standard">
        <title language="en" format="text/plain">Cereals</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <date type="published"><on>2019</on></date>
      </bibitem>
    XML
    data = parser.extract(doc)
    expect(data[:title]).to include "Cereals"
    expect(data[:authoritative_identifier])
      .to include(a_string_including("ISO 712"))
  end

  it "symbolizes template option keys without metanorma-utils" do
    t = Relaton::Render::Template::General.new(
      "template" => { "default" => "{{ x }}" },
    )
    expect(t.instance_variable_get(:@template).keys).to eq [:default]
  end
end
