class UserFollowingsDataFix < ActiveRecord::Migration
  def up
    User.order("id ASC").find_each do |user|
      puts "Creating followings for #{user.id}"
      user.voted_users.each do |voted_user|
        user.follow(voted_user)
      end
    end
  end

  def down
    puts "Irreversible migration"
  end
end
