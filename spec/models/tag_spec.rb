require 'spec_helper'

describe Tag do
  describe 'Attributes' do
    it { should allow_mass_assignment_of(:name) }
  end

  describe 'Validations' do
    subject { FactoryGirl.create(:tag) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'Associations' do
    it { should have_many(:user_tags).dependent(:destroy) }
    it { should have_many(:votes) }
    it { should have_many(:voters).through(:votes) }
  end

  describe 'Create' do
    let(:tag) { FactoryGirl.create(:tag) }
    it "loads into soulmate for autocomplete after save" do
      Tag.search(tag.name).should_not be_empty
    end
  end

  describe 'Destroy' do
    it "removes user tags and votes after deletion" do
      user   = FactoryGirl.create(:user)
      tagger = FactoryGirl.create(:user)
      tagger.add_tags(user, ['design'])
      Vote.count.should == 1

      tag = Tag.find_by_name 'design'
      tag.destroy
      Vote.count.should == 0
    end

    it "is unloaded from soulmate after destroy" do
      tag  = FactoryGirl.create(:tag)
      tag = tag.destroy
      Tag.search(tag.name).detect{|t| t["id"] == tag.id && t["term"] == tag.name}.should be_nil
    end
  end

  describe "user tags counter cache" do
    let(:tag) { FactoryGirl.create(:tag) }

    it "should be increased when a user tag is created" do
      tag.user_tags_count.should == 0
      user   = FactoryGirl.create(:user)
      tagger = FactoryGirl.create(:user)
      tagger.add_tags(user, [tag.name])
      tag.reload.user_tags_count.should == 1
    end
  end
end
