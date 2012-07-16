require 'spec_helper'

describe GiveBrand::Twitter::Importer do

  it "creates following connections for already registered user" do
    user1 = FactoryGirl.create(:user, full_name: "user1")
    authentication1 = FactoryGirl.create(:authentication,
                                    provider: 'twitter', uid: 't1', user: user1)

    user2 = FactoryGirl.create(:user, full_name: "user2")
    authentication2 = FactoryGirl.create(:authentication,
                                    provider: 'twitter', uid: 't2', user: user2)

    user1.followings.should be_empty

    twitter_user = stub(:twitter_user, id: 't2', screen_name: 'screen_name2',
                  name: 'name2', avatar: 'avatar2', profile_image_url: "url2")
    GiveBrand::Twitter::Importer.any_instance.should_receive(:fetch_users).and_return([twitter_user])
    client = stub(:client, current_user: mock(:current_user, screen_name: 'twitter_user'))

    GiveBrand::Twitter::Importer.import(authentication1, client)

    user1.followings.should include(user2)
    user1.reload.twitter_contacts.first.user.should == user2
  end
end
