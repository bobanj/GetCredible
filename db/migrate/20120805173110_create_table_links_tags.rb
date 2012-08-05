class CreateTableLinksTags < ActiveRecord::Migration
  def up
    create_table :links_tags, id: false do |t|
      t.integer :link_id
      t.integer :tag_id
    end

    add_index :links_tags, [:link_id, :tag_id]
    add_index :links_tags, [:tag_id, :link_id]
  end

  def down
    drop_table :links_tags
  end
end
