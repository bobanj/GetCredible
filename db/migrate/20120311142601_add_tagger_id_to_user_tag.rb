class AddTaggerIdToUserTag < ActiveRecord::Migration
  def change
    add_column :user_tags, :tagger_id, :integer
  end
end
