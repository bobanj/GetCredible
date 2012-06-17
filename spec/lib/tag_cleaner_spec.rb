require 'spec_helper'

describe TagCleaner do

  it "can handle nil tags" do
    TagCleaner.clean(nil).should be_empty
  end

  it "can split tags" do
    TagCleaner.clean("developer, designer").should == ["developer", "designer"]
  end

  it "can downcase" do
    TagCleaner.clean("DeveLopeR").should == ["developer"]
  end

  it "can clean non alphabetic characters" do
    TagCleaner.clean("1!23+4developer123@$#4!!)___").should == ["1234developer1234"]
  end

  it "can clean empty spaces" do
    TagCleaner.clean("  developer   ").should == ["developer"]
  end

  it "can remove duplicate tags" do
    TagCleaner.clean("developer, developer").should == ["developer"]
  end

  it "is empty when shitty content" do
    TagCleaner.clean('.....@!!@@^&*@@@",,,,...#@@*&^#').should be_empty
  end
end
