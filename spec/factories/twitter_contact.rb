FactoryGirl.define do
  factory :twitter_contact do |f|
    f.twitter_id  1
    f.screen_name 'pink_panter'
    f.name        'Pink Panter'
    f.avatar      nil
  end
end
