FactoryGirl.define do
  factory :contact do |f|
    f.uid                 1
    f.screen_name         'pink_panter'
    f.name                'Pink Panther'
    f.avatar              nil
    f.provider              'twitter'
  end
end
