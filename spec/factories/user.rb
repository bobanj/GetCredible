FactoryGirl.define do
  factory :user do |user|
    user.sequence(:email) { |i| "user#{i}@example.com" }
    user.password 'password'
    user.sequence(:username) { |i| "user#{i}" }
    user.full_name 'Pink Panter'
    user.job_title 'Actor'
  end
end
