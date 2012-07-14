class TransferTwitterContactsToContacts < ActiveRecord::Migration
  def up
    con
    remove_column :users, :twitter_id
    remove_column :users, :twitter_token
    remove_column :users, :twitter_secret
  end

  def down
    add_column :users, :twitter_id, :integer
    add_column :users, :twitter_token, :string
    add_column :users, :twitter_secret, :string
  end

  def move_twitter_contacts_to_contacts
    User.where('twitter_id is not NULL').find_each do |user|
      user.authentications.where(:provider => 'twitter').destroy_all
      user.create_authentication({:provider => 'twitter',
                                  :uid => user.twitter_id,
                                  :token => user.twitter_token,
                                  :secret => user.twitter_secret
                                 })
    end
  end
end
