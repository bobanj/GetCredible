class AddUsernameToUsers < ActiveRecord::Migration

  def up
    add_column :users, :username, :string

    # migrate slug to username for all users
    User.reset_column_information
    User.all.each do |user|
      user.username = user.slug.to_s.gsub(/\W/, '')
      user.save(validate: false)
    end
  end

  def down
    remove_column :users, :username
  end
end
