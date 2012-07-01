FactoryGirl.define do
  factory :endorsement do |f|
    f.description "Something Pretty Big"
    f.endorser { FactoryGirl.create(:user, full_name: 'Endorser') }
    f.user_tag { FactoryGirl.create(:user_tag) }
  end
end
