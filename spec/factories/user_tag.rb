FactoryGirl.define do
  factory :user_tag do |f|
    f.user   { FactoryGirl.create(:user, full_name: 'Uzumaki Naruto') }
    f.tagger { FactoryGirl.create(:user, full_name: 'Tagger') }
    f.tag    { FactoryGirl.create(:tag, name: 'Ninja') }
  end
end
