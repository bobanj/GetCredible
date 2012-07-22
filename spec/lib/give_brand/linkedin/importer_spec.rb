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

    client = stub(:client)
    linkedin_user = stub(:linkedin_user, id: 'l2',
                         first_name: 'First', last_name: 'Last', picture_url: 'avatar2', url: "url2")

    importer = GiveBrand::Linkedin::Importer.new(authentication1, client)
    importer.current_user.should == user1
    importer.stub(:update_current_user).and_return(true)
    importer.stub(:connections).and_return([linkedin_user])
    importer.import

    user1.followings.should include(user2)
    user1.reload.linkedin_contacts.first.user.should == user2
  end
end
