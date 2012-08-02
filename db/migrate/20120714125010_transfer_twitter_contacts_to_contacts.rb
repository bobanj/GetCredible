class TransferTwitterContactsToContacts < ActiveRecord::Migration
  def up
    Contact.reset_column_information
    drop_table :twitter_contacts
  end

  def down
    create_table "twitter_contacts", :force => true do |t|
      t.integer  "user_id"
      t.integer  "twitter_id"
      t.boolean  "invited",     :default => false
      t.datetime "created_at",                     :null => false
      t.datetime "updated_at",                     :null => false
      t.string   "screen_name"
      t.string   "name"
      t.string   "avatar"
    end
  end
end
