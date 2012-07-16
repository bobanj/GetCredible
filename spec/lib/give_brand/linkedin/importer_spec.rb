require 'spec_helper'

describe GiveBrand::Linkedin::Importer do

  it "creates following connections for already registered user" do
    user1 = FactoryGirl.create(:user, full_name: "user1")
    authentication1 = FactoryGirl.create(:authentication,
                                    provider: 'linkedin', uid: 'l1', user: user1)

    user2 = FactoryGirl.create(:user, full_name: "user2")
    authentication2 = FactoryGirl.create(:authentication,
                                    provider: 'linkedin', uid: 'l2', user: user2)

    user1.followings.should be_empty

    linkedin_user = stub(:linkedin_user, id: 'l2',
     first_name: 'First', last_name: 'Last', picture_url: 'avatar2', url: "url2")

    client = stub(:client, connections: mock(:connections, all: [linkedin_user]))

    GiveBrand::Linkedin::Importer.import(authentication1, client)

    user1.followings.should include(user2)
    user1.reload.linkedin_contacts.first.user.should == user2
  end
end
