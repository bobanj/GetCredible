FactoryGirl.define do
  factory :activity_item do |f|
    f.association :user
    f.item_type 'Tag'
    f.item_id 1
  end
end
