require 'spec_helper'

describe InvitationMessage do
  describe "Validations" do
    it { should validate_presence_of(:inviter) }
    it { should validate_presence_of(:uid) }

    it "validates provider inclusion" do
      invitation_message = FactoryGirl.build(:invitation_message)
      ['twitter', 'linkedin', 'facebook'].each do |provider|
        invitation_message.provider = provider
        invitation_message.valid?.should be_true
      end

      invitation_message.provider = 'invalid'
      invitation_message.valid?.should be_false
      invitation_message.errors[:provider].should include("is not included in the list")
    end
  end

  describe "User invitation" do
    it "can invite contact and make connections" do
      view_context = mock
      user = FactoryGirl.create(:user, full_name: "User")
      authentication = FactoryGirl.create(:authentication, uid: 't1',
                                          provider: 'twitter', user: user)
      contact = FactoryGirl.create(:contact, uid: 't2', authentication: authentication)

      user.followings.should be_empty

      invitation_message = InvitationMessage.new(uid: 't2', provider: 'twitter',
        inviter: user, view_context: view_context, tag1: 'rails')
      invitation_message.should_receive(:send_invitation_message).and_return(true)
      invitation_message.save

      user2 = User.find_by_email('twitter_t2')
      user.followings.should include(user2) # following relationship
      contact.reload.user.should == user2   # temp user - contact relatioship
    end
  end
end
