require 'spec_helper'

describe ActivityItem do

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:item) }
  end

  describe "Database Columns" do
    it { should have_db_column(:user_id) }
    it { should have_db_column(:item_id) }
    it { should have_db_column(:item_type) }
  end

  describe "Behaviour" do
    let(:activity_item) { Factory(:activity_item) }
    let(:user) { Factory(:user) }
    let(:tagger) { Factory(:user) }

    it "is created after user adds a non existing tag" do
      UserTag.add_tags(user, tagger, 'development')
      tagger.activity_items.count.should == 1
      UserTag.add_tags(user, tagger, 'development')
      tagger.activity_items.count.should == 1
      UserTag.add_tags(user, tagger, 'production')
      tagger.activity_items.count.should == 2
    end

    it "is created after user votes for another users tag" do
      UserTag.add_tags(user, tagger, 'development')
      tagger.activity_items.count.should == 1
      UserTag.add_tags(user, tagger, 'development')
      tagger.activity_items.count.should == 1
      UserTag.add_tags(user, tagger, 'production')
      tagger.activity_items.count.should == 2
    end

    it "item is polymorphic" do
      UserTag.add_tags(user, tagger, 'development')
      tagger.outgoing_activities.first.item.should == user.incoming_activities.first.item
      user_tag = user.user_tags.last
      ai = user.activity_items.create(:item => user_tag)
      ai.item_id.should == user_tag.id
      ai.item_type.should == user_tag.class.name
    end
  end
end
