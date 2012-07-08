class CreateIndexForTagUserTagCounter < ActiveRecord::Migration
  def up
    add_index :tags, :user_tags_count
  end

  def down
    remove_index :tags, :user_tags_count
  end
end
