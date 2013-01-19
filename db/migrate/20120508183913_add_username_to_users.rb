class AddUsernameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :username, :string
  end

  def down
    remove_column :users, :username
  end
end
