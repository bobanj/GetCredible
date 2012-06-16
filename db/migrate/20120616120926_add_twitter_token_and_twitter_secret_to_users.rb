class AddTwitterTokenAndTwitterSecretToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
  end
end
