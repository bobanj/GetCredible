class ChangeTwitterContacts < ActiveRecord::Migration
  def up
    add_column :twitter_contacts, :screen_name, :string
    add_column :twitter_contacts, :name, :string
    add_column :twitter_contacts, :avatar, :string
    remove_column :twitter_contacts, :meta_data
  end

  def down
    add_column :twitter_contacts, :meta_data, :text
    remove_column :twitter_contacts, :screen_name
    remove_column :twitter_contacts, :name
    remove_column :twitter_contacts, :avatar
  end
end
