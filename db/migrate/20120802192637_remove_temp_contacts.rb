class RemoveTempContacts < ActiveRecord::Migration
  def up
    drop_table :temp_contacts
  end

  def down
    create_table "temp_contacts", :force => true do |t|
      t.integer  "authentication_id"
      t.string   "uid"
      t.string   "screen_name"
      t.string   "name"
      t.string   "avatar"
      t.string   "url"
      t.boolean  "invited"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.integer  "user_id"
    end
  end
end
