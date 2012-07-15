class TransferTwitterContactsToContacts < ActiveRecord::Migration
  def up
    Contact.reset_column_information
    transfer_twitter_contacts
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

  def transfer_twitter_contacts
     TwitterContact.includes(:user).find_each do |twitter_contact|
       user = twitter_contact.user
       twitter_authentication = user.twitter_authentication
       if twitter_authentication
        twitter_authentication.contacts.create(uid: twitter_contact.twitter_id,
                                               screen_name: twitter_contact.screen_name,
                                               name: twitter_contact.name, avatar: twitter_contact.avatar,
                                               url: "https://twitter.com/#{twitter_contact.screen_name}",
                                               invited: twitter_contact.invited )
       end
     end
  end

end
