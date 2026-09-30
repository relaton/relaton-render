# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe Relaton::Render::Iso690::Template do
  subject(:output) { described_class.new(source).evaluate(fields) }

  let(:field_class) { Relaton::Render::Iso690::Template::Field }
  let(:present_date) { true }
  let(:fields) do
    {
      "creator" => field_class[true, "FARRAR, Frederic William"],
      "title" => field_class[true, "_Eric, or Little by Little_"],
      "date" => field_class[present_date, "1971"],
      "series" => field_class[false, ""],
    }
  end

  context "with all fields present" do
    let(:source) { "{{creator}}. {{title}}. {{date}}." }

    it "joins fields through the literals between them" do
      expect(output).to eq "FARRAR, Frederic William. " \
                           "_Eric, or Little by Little_. 1971."
    end
  end

  context "with a middle field absent" do
    let(:source) { "{{creator}}. {{series}}. {{title}}." }

    it "joins the surviving fields" do
      expect(output).to eq "FARRAR, Frederic William. " \
                           "_Eric, or Little by Little_."
    end
  end

  context "with the final field absent" do
    let(:source) { "{{creator}}. {{title}}. {{date}}." }
    let(:present_date) { false }

    it "still terminates the output" do
      expect(output).to eq "FARRAR, Frederic William. " \
                           "_Eric, or Little by Little_."
    end
  end

  context "with a trailing separator after the last rendered field" do
    let(:source) { "{{surname}}, {{givenNames}}" }
    let(:fields) do
      { "surname" => field_class[true, "HOMER"],
        "givennames" => field_class[false, ""] }
    end

    it "gives up the separator" do
      expect(output).to eq "HOMER"
    end
  end

  context "with output already ending in the terminator" do
    let(:source) { "{{title}}." }

    it "does not double the terminator" do
      expect(output).to eq "_Eric, or Little by Little_."
    end
  end

  context "with a prefix literal" do
    let(:source) { "In: {{title}}." }

    it "attaches it to the field it prefixes" do
      expect(output).to eq "In: _Eric, or Little by Little_."
    end
  end

  context "with no field present" do
    let(:source) { "{{creator}}. {{date}}." }
    let(:fields) do
      { "creator" => field_class[false, ""],
        "date" => field_class[false, ""] }
    end

    it { is_expected.to be_empty }
  end

  context "with slot names differing in case or underscores" do
    let(:fields) do
      { "componentpart" => field_class[true, "In: _A host_"],
        "date" => field_class[true, "1971"] }
    end
    let(:source) { "{{Component_Part}} {{date}}." }

    it "resolves them identically" do
      expect(output).to eq "In: _A host_ 1971."
    end
  end
end
