class AddTwitterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_id, :integer
  end
end
