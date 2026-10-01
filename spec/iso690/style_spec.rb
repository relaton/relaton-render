# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Relaton::Render::Iso690::Style do
  describe ".load" do
    it "loads a named instance from the styles directory" do
      expect(described_class.load("author-date").name)
        .to eq "ISO 690 (name and date)"
    end

    it "loads an instance by path" do
      path = File.join(__dir__, "../fixtures/style-variant.yml")
      expect(described_class.load(path).name).to eq "variant"
    end

    it "raises for an unknown style" do
      expect { described_class.load("chicago") }
        .to raise_error ArgumentError, /unknown style chicago/
    end
  end

  describe "#template_for" do
    subject(:style) { described_class.load("author-date") }

    it "selects the per-type template by clause 8 kind lookup" do
      expect(style.template_for("continuing")).to include "{{componentPart}}"
    end

    it "falls back to the general reference template" do
      expect(style.template_for("moving-image"))
        .to eq style.templates.reference
    end
  end

  describe "#render_name" do
    subject(:style) { described_class.load("author-date") }

    it "upcases the surname through the name template" do
      expect(style.render_name(surname: "Farrar", given: "Frederic William"))
        .to eq "FARRAR, Frederic William"
    end

    it "drops the separator with an absent given name" do
      expect(style.render_name(surname: "Homer", given: "")).to eq "HOMER"
    end
  end

  describe "scheme locale" do
    it "overlays the language pack" do
      style = described_class.load(
        File.join(__dir__, "../fixtures/style-variant.yml"),
      )
      i18n = Relaton::Render::Iso690::I18n.load("fr").overlay!(
        style.scheme.locale,
      )
      expect(i18n.label("and")).to eq "ainsi que"
    end
  end
end
