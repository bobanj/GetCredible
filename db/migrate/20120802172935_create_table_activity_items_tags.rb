class CreateTableActivityItemsTags < ActiveRecord::Migration
  def up
    create_table :activity_items_tags, id: false do |t|
      t.integer :activity_item_id
      t.integer :tag_id
    end

    add_index :activity_items_tags, [:activity_item_id, :tag_id]
    add_index :activity_items_tags, [:tag_id, :activity_item_id]

    puts "remove orphan activity items"
    ActivityItem.all.select{|a| a.target.blank? || a.item.blank?}.map(&:destroy)

    puts "linking activity items with tags"
    ActivityItem.all.each do |activity_item|
      print "."
      if activity_item.item_type == 'Vote'
        activity_item.tags = [activity_item.item.user_tag.tag]
      elsif activity_item.item_type == 'UserTag'
        activity_item.tags = [activity_item.item.tag]
      else #if activity_item.item_type == 'Endorsement'
        activity_item.tags = [activity_item.item.user_tag.tag]
      end
      activity_item.save!
    end
  end

  def down
    drop_table :activity_items_tags
  end
end
