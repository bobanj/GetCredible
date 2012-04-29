class AddUserTagCounterToTag < ActiveRecord::Migration
  def change
    add_column :tags, :user_tags_count, :integer, :default => 0
    Tag.reset_column_information
    Tag.find_each do |t|
      Tag.reset_counters t.id, :user_tags
    end
  end
end
