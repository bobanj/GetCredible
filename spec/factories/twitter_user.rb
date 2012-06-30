FactoryGirl.define do
  factory :twitter_user do |f|
    f.sequence(:email) { |i| "user#{i}@example.com" }
    f.password 'password'
    f.sequence(:username) { |i| "user#{i}" }
    f.full_name 'Pink Panter'
    f.short_bio 'Actor, Ninja, Dish Washer, Fighter'
  end
end
