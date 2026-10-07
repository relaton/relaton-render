# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "relaton/bib"

RSpec.describe Relaton::Render::Iso690::Rules do
  it "resolves a pack's rule selections into the element map" do
    map = described_class.resolve({ "status" => "status_bare" })
    expect(map[:status]).to eq described_class::REGISTRY["status_bare"]
  end

  it "caller elements win over pack selections" do
    override = Class.new
    map = described_class.resolve({ "status" => "status_bare" },
                                  status: override)
    expect(map[:status]).to be override
  end

  it "fails loudly on an unknown rule" do
    expect { described_class.resolve({ "status" => "nonexistent" }) }
      .to raise_error ArgumentError, /unknown citation style rule nonexistent/
  end

  it "the bare status rule cites the stage unparenthesized" do
    model = Relaton::Bib::Item.from_xml(<<~XML)
      <bibitem type="standard" xmlns="http://riboseinc.com/isoxml">
        <title type="main">PAS 9017</title>
        <docidentifier type="BSI">PAS 9017</docidentifier>
        <status><stage>Recommendation</stage></status>
      </bibitem>
    XML
    pack = File.join(Dir.mktmpdir, "status-pack.yml")
    File.write(pack, <<~YML)
      name: bare status pack
      rules:
        status: status_bare
      templates:
        reference: "{{identifier}}. {{status}}."
    YML
    rendered = Relaton::Render::Iso690::Renderer.render(
      model, style: pack, lang: "en",
    )
    expect(rendered).to eq "PAS 9017. Recommendation."
  end
end
