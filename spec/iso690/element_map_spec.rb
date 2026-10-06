# frozen_string_literal: true

require_relative "../spec_helper"
require "relaton/bib"
require "tmpdir"

RSpec.describe "renderer element maps" do
  def bib(xml)
    Relaton::Bib::Bibitem.from_xml(xml)
  end

  let(:no_author) do
    bib(<<~X)
      <bibitem type="standard">
        <title>Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor><role type="publisher"/>
          <organization><name>International Organization</name></organization>
        </contributor>
      </bibitem>
    X
  end

  let(:flavor_style) do
    path = File.join(Dir.mktmpdir, "flavor.yml")
    File.write(path, <<~Y)
      name: flavor slot style
      scheme:
        system: name-date
      templates:
        titleOpen: "_"
        titleClose: "_"
        reference: "{{creator}}. {{title}}{{flavourmark}}. {{identifier}}."
    Y
    path
  end

  it "resolves a flavor slot and a built-in override through the
      elements option alone" do
    marker = Class.new(Relaton::Render::Iso690::Element) do
      def present?
        true
      end

      def render
        " (flavor)"
      end
    end
    creator = Class.new(Relaton::Render::Iso690::Elements::Creator) do
      def present?
        true
      end

      def render
        "Flavor Creator"
      end

      def in_text
        "Flavor"
      end

      def principal_given
        ""
      end
    end
    out = Relaton::Render::Iso690::Renderer.new(
      style: flavor_style,
      elements: { flavourmark: marker, creator: creator },
    ).render(no_author)
    expect(out).to eq "Flavor Creator. _Cereals and cereal products_" \
                      " (flavor). ISO 712."
  end

  it "leaves other renderers of the same process untouched" do
    marker = Class.new(Relaton::Render::Iso690::Element) do
      def present?
        true
      end

      def render
        " (flavor)"
      end
    end
    flavored = Relaton::Render::Iso690::Renderer.new(
      style: flavor_style, elements: { flavourmark: marker },
    )
    plain = Relaton::Render::Iso690::Renderer.new(style: flavor_style)
    expect(flavored.render(no_author)).to include("(flavor)")
    expect(plain.render(no_author)).not_to include("(flavor)")
  end

  it "renders the publisher's name as the creator fallback when a
      style declares it" do
    style = File.join(Dir.mktmpdir, "publisher-name.yml")
    File.write(style, <<~Y)
      name: publisher-name creator fallback
      scheme:
        system: name-date
        nameForm:
          creatorFallback: publisher_name
      templates:
        titleOpen: "_"
        titleClose: "_"
        reference: "{{creator}}. {{title}}. {{identifier}}."
    Y
    out = Relaton::Render::Iso690::Renderer.new(style: style)
      .render(no_author)
    expect(out)
      .to eq "International Organization. " \
             "_Cereals and cereal products_. ISO 712."
  end

  it "renders an identifier kind through an Identifier subclass,
      not a process-wide registry" do
    identifier = Class.new(Relaton::Render::Iso690::Elements::Identifier) do
      def render_id(docidentifier)
        return "#{docidentifier.type}: #{docidentifier.content}" if
          docidentifier.type == "ISO"

        super
      end
    end
    out = Relaton::Render::Iso690::Renderer.new(
      style: "author-date", elements: { identifier: identifier },
    ).render(no_author)
    expect(out).to include("ISO: ISO 712")
  end
end
