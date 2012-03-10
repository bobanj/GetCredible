require 'spec_helper'

describe User do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:remember_me) }
  end

  describe "Database Columns" do
    it { should have_db_column(:email) }
    it { should have_db_column(:encrypted_password) }
    it { should have_db_column(:reset_password_token) }
    #it { should have_db_column(:confirmation_token) }
    it { should have_db_column(:first_name).of_type(:string) }
    it { should have_db_column(:last_name).of_type(:string) }
    it { should have_db_column(:job_title).of_type(:string) }
    it { should have_db_column(:city).of_type(:string) }
    it { should have_db_column(:country).of_type(:string) }
    it { should have_db_column(:twitter_handle).of_type(:string) }
    it { should have_db_column(:personal_url).of_type(:string) }
    it { should have_db_column(:avatar).of_type(:string) }
  end

  describe "Associations" do
    it { should have_many(:user_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:user_tags) }
    it { should have_many(:activity_items).dependent(:destroy) }
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

  describe "#tags_summary" do
    let(:user) { Factory(:user) }

    it "is empty when no user tags" do
      user.tags_summary.should be_empty
    end

    it "sumarizes name and votes" do
      user.add_tags('web design')
      tags = user.tags_summary(nil)
      tags.length.should == 1
      tags[0][:id].should == user.user_tags[0].id
      tags[0][:name].should == "web design"
      tags[0][:votes].should == 0
      tags[0][:voted].should be_false
    end

    it "sumarizes name and votes for a user" do
      user.add_tags('web design')
      user_tag = user.user_tags[0]

      other_user = Factory(:user)
      other_user.vote_exclusively_for(user_tag)

      tags = user.tags_summary(other_user)
      tags.length.should == 1
      tags[0][:id].should == user.user_tags[0].id
      tags[0][:name].should == "web design"
      tags[0][:votes].should == 1
      tags[0][:voted].should be_true
    end
  end
end
