class CreateTwitterContacts < ActiveRecord::Migration
  def change
    create_table :twitter_contacts do |t|
      t.integer :user_id
      t.integer :twitter_id
      t.text :meta_data
      t.boolean :invited, :default => false

      t.timestamps
    end
    add_index :twitter_contacts, :user_id
    add_index :twitter_contacts, :twitter_id
  end
end
