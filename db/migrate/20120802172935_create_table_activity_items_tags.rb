class CreateTableActivityItemsTags < ActiveRecord::Migration
  def up
    create_table :activity_items_tags, id: false do |t|
      t.integer :activity_item_id
      t.integer :tag_id
    end

    add_index :activity_items_tags, [:activity_item_id, :tag_id]
    add_index :activity_items_tags, [:tag_id, :activity_item_id]
  end

  def down
    drop_table :activity_items_tags
  end
end
