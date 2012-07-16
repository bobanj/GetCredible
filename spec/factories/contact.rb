FactoryGirl.define do
  factory :contact do |f|
    f.authentication_id   1
    f.uid                 1
    f.screen_name         'pink_panter'
    f.name                'Pink Panter'
    f.avatar              nil
  end
end
