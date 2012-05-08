Factory.define :user do |f|
  f.sequence(:email)    { |i| "user#{i}@example.com" }
  f.password            'password'
  f.sequence(:username) { |i| "user#{i}" }
  f.full_name           'Pink Panter'
  f.job_title           'Actor'
end
