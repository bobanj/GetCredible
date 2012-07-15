FactoryGirl.define do
  factory :authentication do |f|
    f.provider  'twitter'
    f.uid       'xyz'
    f.secret    'secret'
    f.token     'secret'
  end
end
