require 'spec_helper'

describe Endorsement do
  let(:endorsement) { FactoryGirl.create(:endorsement) }
  let(:user) { FactoryGirl.create(:user) }
  let(:endorser) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:tag) { FactoryGirl.create(:tag, name: 'tag1') }
  let(:user_tag) { FactoryGirl.create(:user_tag, tag: tag, user: user, tagger: other_user) }

  describe "Attributes" do
    it { should allow_mass_assignment_of(:user_tag_id) }
    it { should allow_mass_assignment_of(:endorsed_by_id) }
  end

  describe "Database Columns" do
    it { should have_db_column(:endorsed_by_id).of_type(:integer) }
    it { should have_db_column(:user_tag_id).of_type(:integer) }
    it { should have_db_column(:description).of_type(:text) }
  end

  describe "Associations" do
    it { should have_one(:tag) }
    it { should have_one(:user) }
    it { should belong_to(:user_tag) }
    it { should belong_to(:endorser) }
    it { should allow_mass_assignment_of(:endorser) }
    it { should have_many(:activity_items).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:tag_name) }
    it { should validate_presence_of(:endorser) }
    it { should validate_presence_of(:endorser) }
    it { should validate_presence_of(:user_tag) }
    it { should validate_presence_of(:description) }
    it { should ensure_length_of(:description).is_at_least(10) }
    it { should ensure_length_of(:description).is_at_most(300) }

    it "sets error if user is endorsing himself" do
      endorsement.endorser = user
      endorsement.user_tag = user_tag
      endorsement.description = "This is a valid description bla"
      endorsement.save.should be_false
      endorsement.errors.should_not be_empty
    end
  end

  describe "Endorsement" do
    it "creates vouch (following association) on endorsement" do
      FactoryGirl.create(:endorsement, endorser: endorser, user_tag: user_tag)
      user_tag.reload.votes.length.should == 1
      endorser.reload.voted_users.should include(user)
    end

    it "creates vouch (following association) on endorsement" do
      endorser.add_vote(user_tag, false)
      user_tag.votes.length.should == 1 # sanity
      FactoryGirl.create(:endorsement, endorser: endorser, user_tag: user_tag)
      user_tag.reload.votes.length.should == 1
      endorser.reload.voted_users.should include(user)
    end
  end

  describe "Endorsement without user_tag_id" do
    it "creates a user_tag from user_id and tag_name" do
      endorsement = FactoryGirl.build(:endorsement)
      endorsement.user_tag_id = nil
      endorsement.user_id = user.id
      endorsement.tag_name = "Naruto"
      endorsement.endorser = endorser
      endorsement.valid?
      endorsement.save.should be_true
      endorsement.tag.name.should == "naruto"
      unread_emails_for(user.email).size.should == parse_email_count(0)
    end

    it "validates tag_name and user_id when no user_tag is present" do
      endorsement = FactoryGirl.build(:endorsement)
      endorsement.user_tag_id = nil
      endorsement.endorser = endorser
      endorsement.valid?
      endorsement.save.should be_false
      endorsement.errors[:user_id].should be_present
      endorsement.errors[:tag_name].should be_present
    end

    it "does not validates tag_name and user_id when user_tag is present" do
      endorsement = FactoryGirl.build(:endorsement)
      endorsement.user_tag = user_tag
      endorsement.endorser = endorser
      endorsement.valid?.should be_true
      endorsement.errors[:user_id].should_not be_present
      endorsement.errors[:tag_name].should_not be_present
    end

  end
end
