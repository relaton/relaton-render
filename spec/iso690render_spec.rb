# encoding: utf-8

RSpec.describe Iso690Render do
  it "has a version number" do
    expect(Iso690Render::VERSION).not_to be nil
  end

  it "render book" do
    expect(Iso690Render.parse(<<~INPUT).to be_equivalent_to <<~OUTPUT
    INPUT
    OUTPUT
  end
end
