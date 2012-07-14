require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }
  let(:tagger) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  let(:voter) { FactoryGirl.create(:user) }
  let(:tag) { FactoryGirl.create(:tag, name: 'tag1') }
  let(:tag2) { FactoryGirl.create(:tag, name: 'tag2') }
  let(:user_tag) { FactoryGirl.create(:user_tag, tag: tag, user: user, tagger: tagger) }
  let(:user_tag2) { FactoryGirl.create(:user_tag, tag: tag2, user: user, tagger: tagger) }

  describe "Attributes" do
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:remember_me) }
    it { should allow_mass_assignment_of(:username) }
    it { should allow_mass_assignment_of(:full_name) }
    it { should allow_mass_assignment_of(:short_bio) }
    it { should allow_mass_assignment_of(:location) }
    it { should allow_mass_assignment_of(:personal_url) }
    it { should allow_mass_assignment_of(:twitter_handle) }
    it { should allow_mass_assignment_of(:remote_avatar_url) }
  end

  describe "Database Columns" do
    it { should have_db_column(:email) }
    it { should have_db_column(:encrypted_password) }
    it { should have_db_column(:reset_password_token) }
    it { should have_db_column(:username).of_type(:string) }
    it { should have_db_column(:full_name).of_type(:string) }
    it { should have_db_column(:short_bio).of_type(:string) }
    it { should have_db_column(:location).of_type(:string) }
    it { should have_db_column(:twitter_handle).of_type(:string) }
    it { should have_db_column(:personal_url).of_type(:string) }
    it { should have_db_column(:avatar).of_type(:string) }
  end

  describe "Associations" do
    it { should have_many(:user_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:user_tags) }
    it { should have_many(:activity_items).dependent(:destroy) }
    it { should have_many(:incoming_activities) }
    it { should have_many(:votes).dependent(:destroy) }
    it { should have_many(:voted_users).through(:votes) }
    it { should have_many(:voters).through(:user_tags) }
    it { should have_many(:twitter_contacts).dependent(:destroy) }
    it { should have_many(:friendships).dependent(:destroy) }
    it { should have_many(:reverse_friendships).dependent(:destroy) }
    it { should have_many(:followings) }
    it { should have_many(:followers) }
    it { should have_many(:incoming_endorsements) }
    it { should have_many(:outgoing_endorsements) }
    it { should have_many(:twitter_contacts) }
    it { should have_many(:linkeding_contacts) }
  end

  describe "Validations" do
    subject { FactoryGirl.create(:user) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:username) }
    it { should ensure_length_of(:username).is_at_least(3) }
    it { should ensure_length_of(:short_bio).is_at_most(200) }

    it "validates format of username" do
      user = FactoryGirl.build(:user, username: 'invalid username')
      user.valid?.should be_false
      user.username = 'invalid@username'
      user.valid?.should be_false
      user.username = 'invalid-username'
      user.valid?.should be_false
      user.username = ' invalid-username'
      user.valid?.should be_false
      user.username = 'invalid-username '
      user.valid?.should be_false
      user.username = 'valid_username'
      user.valid?.should be_true
      user.username = 'validusername'
      user.valid?.should be_true
    end

    it "validates format of personal_url when not blank" do
      user = FactoryGirl.build(:user, personal_url: 'test')
      user.should_not be_valid
      user.errors[:personal_url].should include("is not a valid url")
    end

    it "does not validate format of personal_url when blank" do
      user = FactoryGirl.build(:user, :personal_url => '')
      user.should be_valid
    end

    it "validates that username is not a route" do
      user = FactoryGirl.build(:user, username: 'tour')
      user.valid?.should be_false
      user.errors[:username].should include("is not available")

      user.username = 'tour/invalid_route'
      user.valid?.should_not raise_exception lambda { ActionController::RoutingError }
      user.valid?.should be_false
      user.errors[:username].should include("is not available")

      user.username = 'unique_id'
      user.valid?.should be_true
    end
  end

  describe "Callbacks" do
    it "adds protocol and removes empty spaces from personal_url" do
      user = FactoryGirl.build(:user, :personal_url => ' givebrand.to ')
      user.valid?.should be_true
      user.personal_url.should == 'http://givebrand.to'
    end

    it "removes empty spaces from personal_url" do
      user = FactoryGirl.build(:user, :personal_url => ' http://givebrand.to ')
      user.valid?.should be_true
      user.personal_url.should == 'http://givebrand.to'
    end

    it "removes @ sign and empty spaces from twitter username" do
      user = FactoryGirl.build(:user, twitter_handle: ' @pink_panter ')
      user.valid?.should be_true
      user.twitter_handle.should == 'pink_panter'
    end

    it "removes empty spaces from twitter username" do
      user = FactoryGirl.build(:user, twitter_handle: ' pink_panter ')
      user.valid?.should be_true
      user.twitter_handle.should == 'pink_panter'
    end
  end

  describe "#add_vote" do
    it "can add a vote for user tag" do
      voter.add_vote(user_tag)
      user_tag.votes.length.should == 1
    end

    it "returns true when vote is added" do
      voter.add_vote(user_tag).should be_true
    end

    it "cannot add double votes" do
      voter.add_vote(user_tag).should be_true
      voter.add_vote(user_tag).should be_true
      voter.votes.length.should == 1
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

    it "returns true when vote is removed" do
      voter.add_vote(user_tag)
      user_tag.votes.length.should == 1
      voter.remove_vote(user_tag).should be_true
    end

    it "returns false when vote is not removed" do
      voter.remove_vote(user_tag).should be_false
    end

    it "removes user tag if only 1 vote" do
      tagger.add_tags(user, ['development'])
      user_tag = user.user_tags.first
      tagger.remove_vote(user_tag).should be_true
      UserTag.count.should == 0
    end

    it "does not remove user tag if more than 1 vote" do
      tagger.add_tags(user, ['development'])
      user_tag = user.user_tags.first
      voter.add_vote(user_tag)
      tagger.remove_vote(user_tag).should be_true
      UserTag.count.should == 1
    end
  end

  describe "#top_tags" do
    it "can find top tags" do
      tagger.add_tags(user, ['design', 'development', 'management', 'leadership'])

      design      = user.user_tags[0]
      development = user.user_tags[1]
      management  = user.user_tags[2]
      leadership  = user.user_tags[3]

      voter.vote_exclusively_for(development)
      voter.vote_exclusively_for(management)

      top_tags = user.top_tags(2)
      top_tags.each { |top_tag| top_tag.class.should == Tag }
      tag_names = top_tags.map{|t| t.name }
      tag_names.should include('development')
      tag_names.should include('management')
    end
  end

  describe "#interacted_by" do
    it "returns false when no interaction" do
      user = FactoryGirl.create(:user)
      other_user = FactoryGirl.create(:user)
      other_user.interacted_by(user).should be_false
    end

    it "returns true when other user has voted for a tag interaction" do
      tagger.add_tags(user, ['web design'])
      user.interacted_by(tagger).should be_true
    end
  end

  describe "#outgoing_activities" do
    it "returns outgoing activities" do
      tagger.add_tags(user, ['development']) # logs only tag, not vote
      user_tag = user.user_tags.first
      tagger.add_vote(user_tag2) # logs vote
      vote = user_tag2.votes.last

      outgoing_activities = tagger.outgoing_activities
      outgoing_activities.length.should == 2
      outgoing_activities[0].item.should == vote
      outgoing_activities[1].item.should == user_tag
    end

    it "does not return activities for inactive users" do
      invited = User.invite!({email: 'invited1@example.com', tag_names: ['tag1']}, tagger)
      tagger.add_tags(invited, TagCleaner.clean(['tag1']), skip_email: true)

      tagger.outgoing_activities.should be_empty
    end
  end

  describe "#incoming_activities" do
    it "returns incoming activities" do
      tagger.add_tags(user, ['development']) # logs only tag, not vote
      user_tag = user.user_tags[0]
      tagger.add_vote(user_tag2) # logs vote
      vote = user_tag2.votes.first

      incoming_activities = user.incoming_activities
      incoming_activities.length.should == 2
      incoming_activities[0].item.should == vote
      incoming_activities[1].item.should == user_tag
    end
  end

  describe "#all_activities" do
    it "returns incoming and outgoing activities" do
      tagger.add_tags(user, ['development'])
      user_tag1 = user.user_tags[0]

      user.add_tags(tagger, ['development'])
      user_tag2 = tagger.user_tags[0]

      tagger.add_vote(user_tag) # logs vote
      vote = user_tag.votes.first

      all_activities = user.all_activities
      all_activities.length.should == 3
      all_activities[0].item.should == vote
      all_activities[1].item.should == user_tag2
      all_activities[2].item.should == user_tag1
    end

    it "returns friends of friends activities" do
      user_tag = FactoryGirl.create(:user_tag, tag: tag, user: user, tagger: tagger)

      voter.add_vote(user_tag)
      vote = user_tag.votes.first

      user.add_tags(voter, ['development'])
      user_tag = voter.user_tags.first

      all_activities = user.all_activities
      all_activities.length.should == 2
      all_activities[0].item.should == user_tag
      all_activities[1].item.should == vote
    end

    it "does not return activities for inactive users" do
      invited = User.invite!({email: 'invited1@example.com', tag_names: ['tag1']}, user)
      user.add_tags(invited, TagCleaner.clean(['tag1']), skip_email: true)

      user.all_activities.should be_empty
    end
  end

  describe "#short_name" do
    it "returns 'Pink' when full_name is 'Pink'" do
      user = FactoryGirl.build(:user, full_name: 'Pink')
      user.short_name.should == 'Pink'
    end

    it "returns 'Pink' when full_name is 'Pink Panter'" do
      user = FactoryGirl.build(:user, full_name: 'Pink Panter')
      user.short_name.should == 'Pink'
    end
  end

  describe "#search" do
    it "can find users by tag" do
      tagger.add_tags(user, ['development'])
      users = User.search(q: 'development')
      users.should include(user)
    end

    it "can find users by name" do
      user = FactoryGirl.create(:user, full_name: 'Pink Panter')
      users = User.search(q: 'Panter')
      users.should include(user)
    end

    it "can find users by username" do
      user = FactoryGirl.create(:user, username: 'green_panter')
      users = User.search(q: 'green')
      users.should include(user)
    end

    it "returns no user when query is blank" do
      user = FactoryGirl.create(:user, full_name: 'Pink Panter')
      users = User.search(q: '')
      users.should_not include(user)
    end
  end

  describe "#full_name" do
    it "returns username when full_name is blank" do
      user = FactoryGirl.build(:user, :full_name => '', :username => 'pink-panter')
      user.name.should == 'pink-panter'
    end

    it "returns full_name when full_name is present" do
      user = FactoryGirl.build(:user, :full_name => 'Pink Panter', :username => 'p')
      user.full_name.should == 'Pink Panter'
    end
  end

  describe "#change_error_message" do
    it "does not change error message for attribute if no error exist" do
      user.change_error_message(:email, 'you shell not pass')
      user.errors[:email].should be_empty
    end

    it "changes error message for attribute if error exist" do
      existing_user = FactoryGirl.build(:user, :email => user.email)
      existing_user.valid?.should be_false
      existing_user.errors[:email].should_not be_empty
      existing_user.change_error_message(:email, 'you shell not pass')
      existing_user.errors[:email].should == ['you shell not pass']
    end
  end

  describe 'Endorsments' do
    it "can endorse tag of other user" do
      endorser = FactoryGirl.create(:user, full_name: 'Endorser')
      user_tag.endorsements.count.should == 0
      endorser.endorse(user_tag, 'this is text with minimum 10 characters')
      user_tag.reload.endorsements.count.should == 1
    end

    it "can not endorse tags he owns" do
      user_tag.endorsements.count.should == 0
      user.endorse(user_tag,'this is text with minimum 10 characters')
      user_tag.endorsements.count.should == 0
    end

    it "destroys endorsments after deleting user" do
      endorser = FactoryGirl.create(:user, full_name: 'Endorser')
      user_tag.endorsements.count.should == 0
      endorser.endorse(user_tag, 'this is text with minimum 10 characters')
      user_tag.endorsements.count.should == 1
      endorser.destroy
      user_tag.endorsements.count.should == 0
    end
  end

  describe "user relationships" do
    describe "#voters" do
      it "returns the users that have voted the user" do
        voter.add_vote(user_tag)
        user.voters.should include(voter)
      end
    end

    describe "#voted_users" do
      it "returns the users that have been voted by the user" do
        voter.add_vote(user_tag)
        voter.voted_users.should include(user)
      end
    end

    describe "#friends" do
      it "returns the users that both interacted with the user" do
        voter.add_vote(user_tag)
        user.add_tags(voter, ['development'])
        user.friends.should include(voter)
      end
    end

    describe "#voted_count" do
      it "returns number of supported people" do
        voter.add_vote(user_tag)
        voter.add_vote(user_tag2)
        voter.voted_count.should == 1
      end
    end

    describe "#voters_count" do
      it "returns number of supporters" do
        voter.add_vote(user_tag)
        voter.add_vote(user_tag2)
        user.voters_count.should == 1
      end
    end
  end
end
