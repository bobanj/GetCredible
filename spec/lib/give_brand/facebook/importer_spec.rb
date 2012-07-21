require 'spec_helper'

describe GiveBrand::Facebook::Importer do

  it "creates following connections for already registered user" do
    user1 = FactoryGirl.create(:user, full_name: "user1")
    authentication1 = FactoryGirl.create(:authentication,
                                    provider: 'facebook', uid: 'f1', user: user1)

    user2 = FactoryGirl.create(:user, full_name: "user2")
    authentication2 = FactoryGirl.create(:authentication,
                                    provider: 'facebook', uid: 'f2', user: user2)

    user1.followings.should be_empty
    GiveBrand::Facebook::Importer.should_receive(:update_current_user).
      with(user1).and_return(true)

    facebook_user = {'uid' => 'f2', 'name' => 'First Last',
                     'pic' => 'avatar2', 'profile_url' => "url2"}

    client = stub(:client, fql_query: [facebook_user])

    GiveBrand::Facebook::Importer.import(authentication1, client)

    user1.followings.should include(user2)
    user1.reload.facebook_contacts.first.user.should == user2
  end
end
