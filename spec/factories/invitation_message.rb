FactoryGirl.define do
  factory :invitation_message do |f|
    f.inviter   '1'
    f.uid       '1'
    f.provider  'twitter'
    f.tag1 'rails'
  end
end
