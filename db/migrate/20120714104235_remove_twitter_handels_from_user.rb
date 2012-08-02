class RemoveTwitterHandelsFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :twitter_id
    remove_column :users, :twitter_token
    remove_column :users, :twitter_secret
  end

  def down
    add_column :users, :twitter_id, :integer
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
  end
end
