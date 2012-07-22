class RenameContactsToTempContacts < ActiveRecord::Migration
  def up
    remove_index :contacts, :authentication_id
    remove_index :contacts, :uid
    remove_index :contacts, [:authentication_id, :uid]
    rename_table :contacts, :temp_contacts
    add_index :temp_contacts, :authentication_id
    add_index :temp_contacts, :uid
    add_index :temp_contacts, [:authentication_id, :uid]
  end

  def down
    rename_table :temp_contacts, :contacts
  end
end
