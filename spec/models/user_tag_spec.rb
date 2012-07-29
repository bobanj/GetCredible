require 'spec_helper'

describe UserTag do
  let(:user) { FactoryGirl.create(:user) }
  let(:tagger) { FactoryGirl.create(:user) }
  let(:tag)  { FactoryGirl.create(:tag) }

  describe 'Attributes' do
    it { should allow_mass_assignment_of(:user_id) }
    it { should allow_mass_assignment_of(:tag_id) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:tag) }
    it { should belong_to(:tagger) }
    it { should have_many(:activity_items).dependent(:destroy) }
    it { should have_many(:votes).dependent(:destroy) }
    it { should have_many(:voters).through(:votes) }
    it { should have_many(:last_voters).through(:votes) }
    it { should have_many(:last_voters).through(:votes) }
    it { should have_many(:endorsements).dependent(:destroy) }
    it { should have_many(:endorsers).through(:endorsements) }
  end

  describe 'Validations' do
    subject { FactoryGirl.create(:user_tag,  user: user,  tag: tag, tagger: tagger) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:tag_id) }
    it { should validate_uniqueness_of(:tag_id).scoped_to(:user_id) }
  end

  describe "#add_tags" do
    it "does not create a tag when tag_names is empty" do
      UserTag.add_tags(tagger, user, [])
      user.tags.should be_empty
    end

    it "creates a tag when tag_names are single tag" do
      UserTag.add_tags(tagger, user, ['development'])
      user.tags.length.should == 1
      user.tags[0].name.should == 'development'
    end

    it "creates a tag when tag_names are multiple tags" do
      UserTag.add_tags(tagger, user, ['development', 'design', 'management'])
      user.tags.length.should == 3
      user.tags[0].name.should == 'design'
      user.tags[1].name.should == 'development'
      user.tags[2].name.should == 'management'
    end

    it "creates a tag when tag_names are multiple tags with multiple words" do
      UserTag.add_tags(tagger, user, ['web design', 'project management'])
      user.tags.length.should == 2
      user.tags[0].name.should == 'project management'
      user.tags[1].name.should == 'web design'
    end

    it "does not create duplicate tags for a user" do
      UserTag.add_tags(tagger, user, ['web design', 'web design', 'web design'])
      Tag.count.should == 1
      user.tags.length.should == 1
      user.tags[0].name.should == 'web design'
    end

    it "creates activity item for tagger after user is tagged" do
      UserTag.add_tags(tagger, user, ['development'])
      tagger.activity_items.count.should == 1
      tagger.activity_items.where("item_type = 'UserTag'").length.should == 1
      tagger.activity_items.where("item_type = 'Vote'").length.should == 0

      UserTag.add_tags(tagger, user, ['development'])
      tagger.activity_items.count.should == 2
      tagger.activity_items.where("item_type = 'UserTag'").length.should == 1
      tagger.activity_items.where("item_type = 'Vote'").length.should == 1

      UserTag.add_tags(tagger, user, ['production'])
      tagger.activity_items.count.should == 3
      tagger.activity_items.where("item_type = 'UserTag'").length.should == 2
      tagger.activity_items.where("item_type = 'Vote'").length.should == 1
    end

    it "creates vouch if tag already exists" do
      UserTag.add_tags(tagger, user, ['web design'])
      Tag.count.should == 1
      user.tags.length.should == 1
      user.user_tags[0].votes.length.should == 1
      user.tags[0].name.should == 'web design'

      # if the same user tags, it should not create vouch
      UserTag.add_tags(tagger, user, ['web design'])
      Tag.count.should == 1
      user.tags.length.should == 1
      user.user_tags[0].reload.votes.length.should == 1
      user.tags[0].name.should == 'web design'

      # if other user tags, it should create a vouch
      other_tagger = FactoryGirl.create(:user)
      UserTag.add_tags(other_tagger, user, ['web design'])
      Tag.count.should == 1
      user.tags.length.should == 1
      user.user_tags[0].reload.votes.length.should == 2
      user.tags[0].name.should == 'web design'
    end

    it "creates follow association after adding new tag" do
      UserTag.add_tags(tagger, user, ['development'])
      tagger.followings.should include(user)
    end

    it "creates follow association after voting for tag" do
      UserTag.add_tags(tagger, user, ['development'])
      tagger.followings.should include(user)
    end

  end


end
