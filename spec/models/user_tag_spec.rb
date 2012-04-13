require 'spec_helper'

describe UserTag do
  let(:user) { Factory(:user) }
  let(:tagger) { Factory(:user) }
  let(:tag)  { Factory(:tag) }
  let(:tagger) { Factory(:user) }

  describe 'Attributes' do
    it { should allow_mass_assignment_of(:user_id) }
    it { should allow_mass_assignment_of(:tag_id) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:tag) }
    it { should belong_to(:tagger) }
    it { should have_many(:activity_items).dependent(:destroy) }
  end

  describe 'Validations' do
    subject { Factory(:user_tag,  user: user,  tag: tag, tagger: tagger) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:tag_id) }
    it { should validate_uniqueness_of(:tag_id).scoped_to(:user_id) }
  end

  describe "#add_tags" do
    it "does not create a tag when tag_names is empty" do
      UserTag.add_tags(user, tagger, [])
      user.tags.should be_empty
    end

    it "creates a tag when tag_names are single tag" do
      UserTag.add_tags(user, tagger, ['development'])
      user.tags.length.should == 1
      user.tags[0].name.should == 'development'
    end

    it "creates a tag when tag_names are multiple tags" do
      UserTag.add_tags(user, tagger, ['development', 'design', 'management'])
      user.tags.length.should == 3
      user.tags[0].name.should == 'development'
      user.tags[1].name.should == 'design'
      user.tags[2].name.should == 'management'
    end

    it "creates a tag when tag_names are multiple tags with multiple words" do
      UserTag.add_tags(user, tagger, ['web design', 'project management'])
      user.tags.length.should == 2
      user.tags[0].name.should == 'web design'
      user.tags[1].name.should == 'project management'
    end

    it "does not create duplicate tags for a user" do
      UserTag.add_tags(user, tagger, ['web design', 'web design', 'web design'])
      Tag.count.should == 1
      user.tags.length.should == 1
      user.tags[0].name.should == 'web design'
    end

    it "creates activity item for tagger after user is tagged" do
      UserTag.add_tags(user, tagger, ['development'])
      tagger.activity_items.count.should == 1
      UserTag.add_tags(user, tagger, ['development'])
      tagger.activity_items.count.should == 1
      UserTag.add_tags(user, tagger, ['production'])
      tagger.activity_items.count.should == 2
    end
  end

  describe "#tags_summary" do
    it "is empty when no user tags" do
      user.tags_summary.should be_empty
    end

    it "sumarizes name and votes" do
      UserTag.add_tags(user, tagger, ['web design'])
      tags = user.tags_summary(nil)
      tags.length.should == 1
      tags[0][:id].should == user.user_tags[0].id
      tags[0][:name].should == "web design"
      tags[0][:votes].should == 0
      tags[0][:voted].should be_false
    end

    it "sumarizes name and votes for a user" do
      UserTag.add_tags(user, tagger, ['web design'])
      user_tag = user.user_tags[0]

      tagger.vote_exclusively_for(user_tag)

      tags = user.tags_summary(tagger)
      tags.length.should == 1
      tags[0][:id].should == user.user_tags[0].id
      tags[0][:name].should == "web design"
      tags[0][:votes].should == 1
      tags[0][:voted].should be_true
    end
  end
end
