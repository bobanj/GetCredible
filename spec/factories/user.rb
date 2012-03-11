Factory.define :user do |f|
  f.sequence(:email) { |i| "user_#{i}@getcredible.com" }
  f.password         'password'
  f.first_name "Naruto"
  f.last_name "Uzumaki"
  f.job_title "Ninja"
end
