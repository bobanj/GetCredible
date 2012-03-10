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

  describe "#add_tags" do
    let(:user) { Factory(:user) }

    it "does not create a tag when tag_names is nil" do
      user.add_tags(nil)
      user.tags.should be_empty
    end

    it "does not create a tag when tag_names is empty" do
      user.add_tags('')
      user.tags.should be_empty
    end

    it "creates a tag when tag_names are single tag" do
      user.add_tags('development')
      user.tags.length.should == 1
      user.tags[0].name.should == 'development'
    end

    it "creates a tag when tag_names are multiple tags" do
      user.add_tags('development, design, management')
      user.tags.length.should == 3
      user.tags[0].name.should == 'development'
      user.tags[1].name.should == 'design'
      user.tags[2].name.should == 'management'
    end

    it "creates a tag when tag_names are multiple tags with multiple words" do
      user.add_tags('web design, project management')
      user.tags.length.should == 2
      user.tags[0].name.should == 'web design'
      user.tags[1].name.should == 'project management'
    end

    it "does not create duplicate tags for a user" do
      user.add_tags('web design, web design, web design')
      Tag.count.should == 1
      user.tags.length.should == 1
      user.tags[0].name.should == 'web design'
    end
  end
end
