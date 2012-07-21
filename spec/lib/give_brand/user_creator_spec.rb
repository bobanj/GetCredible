require 'spec_helper'

describe GiveBrand::UserCreator do
  let(:inviter) { FactoryGirl.create(:user) }
  let(:authentication) { FactoryGirl.create(:authentication,
      provider: 'twitter', user: inviter, uid: 'uid1') }
  let(:contact) { FactoryGirl.create(:contact, authentication: authentication,
      uid: 'uid2', screen_name: 'pink_panter') }
  let(:invitation_message) { InvitationMessage.new(tag_names: ['rails'],
      uid: 'uid2', provider: 'twitter', inviter: inviter) }

  it "can create new user" do
    user_creator = GiveBrand::UserCreator.new(invitation_message, contact)
    user = user_creator.create

    user.email.should == "twitter_uid2"
    user.tags.map(&:name).should == ['rails']
    user.followers.should include(inviter)
  end

  it "does not creates duplicate and returns existing user" do
    user_creator = GiveBrand::UserCreator.new(invitation_message, contact)
    user1 = user_creator.create
    User.count.should == 2

    user_creator2 = GiveBrand::UserCreator.new(invitation_message, contact)
    user2 = user_creator2.create
    User.count.should == 2
    user1.should == user2
  end
end
