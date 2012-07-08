FactoryGirl.define do
  factory :friendship do |f|
    f.follower { FactoryGirl.create(:user, full_name: 'Follower') }
    f.followed { FactoryGirl.create(:user, full_name: 'Followed') }
  end
end
