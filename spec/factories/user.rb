Factory.define :user do |f|
  f.sequence(:email) { |i| "user_#{i}@getcredible.com" }
  f.password         'password'
end
