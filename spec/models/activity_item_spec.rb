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

    it "is created after user adds a non existing tag" do
      user.add_tags('development')
      user.activity_items.count.should == 1
      user.add_tags('development')
      user.activity_items.count.should == 1
      user.add_tags('production')
      user.activity_items.count.should == 2
    end

    it "item is polymorphic" do
      user.add_tags('development')
      user.activity_items.last.item.should == Tag.find_by_name('development')
      user_tag = user.user_tags.last
      ai = user.activity_items.create(:item => user_tag)
      ai.item_id.should == user_tag.id
      ai.item_type.should == user_tag.class.name
    end


  end

end
