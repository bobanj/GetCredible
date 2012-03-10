# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
usernames = ["test","voter"]
password = "asdfasdf"
usernames.each do |username|
  email = "#{username}@test.com"
  user = User.find_by_email email
  unless user
    puts "Setting up Test user with: #{email} / #{password}"
    user = User.create :email => email, :password => password, :password_confirmation => password
    user.save!
  end
end

