# encoding: utf-8

RSpec.describe Cnccs do
  it "has a version number" do
    expect(Cnccs::VERSION).not_to be nil
  end

  it "fetch field" do
    ccs = Cnccs.fetch fieldcode: "J"
    expect(ccs.code).to eq "J"
    expect(ccs.fieldcode).to eq "J"
    expect(ccs.description).to eq "机械"
    expect(ccs.notes).to be_instance_of Array
    expect(ccs.notes.size).to eq 0
  end

  it "fetch group" do
    ccs = Cnccs.fetch fieldcode: "J", groupcode: "90/99"
    expect(ccs.code).to eq "J90/99"
    expect(ccs.groupcode).to eq "90/99"
    expect(ccs.description).to eq "活塞式内燃机与其他动力设备"
    expect(ccs.description_full).to eq "机械; 活塞式内燃机与其他动力设备"
    expect(ccs.fieldcode).to eq "J"
    expect(ccs.notes.size).to eq 6
  end

  it "fetch subgroup" do
    ccs = Cnccs.fetch subgroupcode: "J98"
    expect(ccs.code).to eq "J98"
    expect(ccs.fieldcode).to eq "J"
    expect(ccs.groupcode).to eq "90/99"
    expect(ccs.description).to eq "锅炉及其辅助设备"
    expect(ccs.description_full).to eq "机械; 活塞式内燃机与其他动力设备; 锅炉及其辅助设备"
    expect(ccs.notes.size).to eq 3

    note = ccs.notes[1]
    expect(note.text).to eq "锅炉高能点火器入{ccs-code}"
    expect(note.ccs_code).to eq "T37"
    expect(note.ccs.description).to eq "点火装置"
  end

  it "fetch by code" do
    ccs = Cnccs.fetch "J98"
    expect(ccs.description_full).to eq "机械; 活塞式内燃机与其他动力设备; 锅炉及其辅助设备"

    ccs = Cnccs.fetch "J"
    expect(ccs.description).to eq "机械"
  end
end
