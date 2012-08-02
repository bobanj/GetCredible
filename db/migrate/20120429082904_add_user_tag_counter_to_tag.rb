class AddUserTagCounterToTag < ActiveRecord::Migration
  def up
    add_column :tags, :user_tags_count, :integer, :default => 0
  end

  def down
    remove_column :tags, :user_tags_count
  end
end
