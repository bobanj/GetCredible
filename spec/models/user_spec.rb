require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }
  let(:voter) { Factory(:user) }
  let(:tag) { Factory(:tag) }
  let(:user_tag) { Factory(:user_tag, tag: tag, user: user) }

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

  describe "Validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:job_title) }
  end

  describe "#add_vote" do
    it "can add a vote for user tag" do
      voter.add_vote(user_tag)
      user_tag.votes.length.should == 1
    end

    it "returns true when vote is added" do
      voter.add_vote(user_tag).should be_true
    end

    it "cannot add a vote the same user" do
      user.add_vote(user_tag).should be_false
    end

    it "creates activity item for voter after user tag is voted for" do
      voter.add_vote(user_tag)
      voter.activity_items.count.should == 1
    end
  end

  describe "#remove_vote" do
    it "can remove a vote from a user tag" do
      voter.add_vote(user_tag)
      user_tag.votes.length.should == 1
      voter.remove_vote(user_tag)
      user_tag.reload.votes.length.should == 0
    end

    it "returns true when vote is remove" do
      voter.add_vote(user_tag)
      user_tag.votes.length.should == 1
      voter.remove_vote(user_tag).should be_true
    end

    it "returns false when vote is not remove" do
      voter.remove_vote(user_tag).should be_false
    end
  end

  describe "#top_tags" do
    it "can find top tags" do
      user  = Factory(:user)
      user2 = Factory(:user)
      user3 = Factory(:user)

      UserTag.add_tags(user, user2, 'design, development, management, leadership')

      design      = user.user_tags[0]
      development = user.user_tags[1]
      management  = user.user_tags[2]
      leadership  = user.user_tags[3]

      user2.vote_exclusively_for(design)
      user2.vote_exclusively_for(development)
      user2.vote_exclusively_for(management)

      user3.vote_exclusively_for(development)
      user3.vote_exclusively_for(management)
      user3.vote_exclusively_for(leadership)

      top_tags = user.top_tags(4)

      tag_names = top_tags.map{|t| t[:name] }
      tag_names.should include('development')
      tag_names.should include('management')

      top_tags[0][:votes].should == '2'
      top_tags[1][:votes].should == '2'
    end
  end

  describe "#interacted_by" do
    it "returns false when no interaction" do
      user = Factory(:user)
      other_user = Factory(:user)
      other_user.interacted_by(user).should be_false
    end

    it "returns true when other user has voted for a tag interaction" do
      user = Factory(:user)
      other_user = Factory(:user)

      UserTag.add_tags(user, other_user, 'web design')
      user_tag = user.user_tags[0]

      other_user.vote_exclusively_for(user_tag)

      user.interacted_by(other_user).should be_true
    end
  end


  describe "#ongoing_activities" do
    it "item is polymorphic" do
      pending
      UserTag.add_tags(user, tagger, 'development')
      tagger.outgoing_activities.first.item.should == user.incoming_activities.first.item
      user_tag = user.user_tags.last
      ai = user.activity_items.create(:item => user_tag)
      ai.item_id.should == user_tag.id
      ai.item_type.should == user_tag.class.name
    end
  end
end
