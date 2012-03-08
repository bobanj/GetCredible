require 'spec_helper'

describe User do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:remember_me) }
  end

  describe "Associations" do
    it { should have_many(:user_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:user_tags) }
  end

  describe "#tag" do
    let(:user) { Factory(:user) }

    it "can handle nil tag_names" do
      user.tag(nil)
      user.tags.should be_empty
    end

    it "can handle empty string tag_names" do
      user.tag('')
      user.tags.should be_empty
    end

    it "can handle sigle tag" do
      user.tag('development')
      user.tags.length.should == 1
      user.tags[0].name.should == 'development'
    end

    it "can handle multiple tags" do
      user.tag('development, design, management')
      user.tags.length.should == 3
      user.tags[0].name.should == 'development'
      user.tags[1].name.should == 'design'
      user.tags[2].name.should == 'management'
    end

    it "can handle tags with words" do
      user.tag('web design, project management')
      user.tags.length.should == 2
      user.tags[0].name.should == 'web design'
      user.tags[1].name.should == 'project management'
    end

    it "does not create multiple tags for a user" do
      user.tag('web design, web design, web design')
      Tag.count.should == 1
      user.tags.length.should == 1
      user.tags[0].name.should == 'web design'
    end
  end
end
