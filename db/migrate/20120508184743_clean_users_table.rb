class CleanUsersTable < ActiveRecord::Migration
  def up
    rename_column :users, :city, :location
    remove_column :users, :country
    remove_column :users, :slug
  end

  def down
    rename_column :users, :location, :city
    add_column :users, :country, :string
    add_column :users, :slug, :string
  end
end
