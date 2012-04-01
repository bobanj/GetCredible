Factory.define :user do |f|
  f.sequence(:email) { |i| "user_#{i}@getcredible.com" }
  f.password         'password'
  f.full_name "Uzumaki Naruto"
  f.job_title "Ninja"
end
