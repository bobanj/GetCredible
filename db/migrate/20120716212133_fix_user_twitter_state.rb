class FixUserTwitterState < ActiveRecord::Migration
  def up
    User.find_each do |user|
      twitter_authentication = user.twitter_authentication
      if twitter_authentication && twitter_authentication.contacts.count > 0
        user.twitter_state = 'finished'
        user.save
      end
    end
  end

  def down
  end
end
