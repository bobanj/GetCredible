FactoryGirl.define do
  factory :activity_item do |activity_item|
    activity_item.association :user
    activity_item.item_type 'Tag'
    activity_item.item_id 1
  end
end
