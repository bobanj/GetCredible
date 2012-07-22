require 'spec_helper'

describe GiveBrand::Twitter::Importer do

  it "creates following connections for already registered user" do
    user1 = FactoryGirl.create(:user, full_name: "user1")
    authentication1 = FactoryGirl.create(:authentication,
                                         provider: 'twitter', uid: 't1', user: user1)

    user2 = FactoryGirl.create(:user, full_name: "user2")
    FactoryGirl.create(:authentication, provider: 'twitter', uid: 't2', user: user2)

    user1.followings.should be_empty

    client = stub(:client)
    twitter_user = stub(:twitter_user, id: 't2',
                        screen_name: 'bbbman', name: 'Batman', profile_image_url: 'avatar2', url: "url2",)

    importer = GiveBrand::Twitter::Importer.new(authentication1, client)
    importer.current_user.should == user1
    importer.stub(:update_current_user).and_return(true)
    importer.stub(:connections).and_return([twitter_user])
    importer.import

    user1.followings.should include(user2)
    user1.reload.twitter_contacts.first.user.should == user2
  end
end
