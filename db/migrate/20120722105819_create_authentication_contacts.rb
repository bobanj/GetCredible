class CreateAuthenticationContacts < ActiveRecord::Migration
  def change
    create_table :authentication_contacts do |t|
      t.integer :authentication_id
      t.integer :contact_id
      t.boolean :invited

      t.timestamps
    end
    add_index :authentication_contacts, :authentication_id
    add_index :authentication_contacts, :contact_id
    add_index :authentication_contacts, [:authentication_id, :contact_id], :unique => true, :name => 'index_ac_on_authentication_id_and_contact_id'
  end
end
