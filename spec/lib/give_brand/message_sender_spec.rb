require 'spec_helper'

describe GiveBrand::MessageSender do
  let(:inviter) { FactoryGirl.create(:user) }
  let(:contact) { FactoryGirl.create(:contact,
      uid: 'uid2', screen_name: 'pink_panter') }
  let(:receiver_uid) { 'uid1' }
  let(:client) { mock }

  def create_invitation_message(provider)
    InvitationMessage.new(tag_names: ['rails'],
      uid: 'uid2', provider: provider, screen_name: 'pink_panter', inviter: inviter)
  end

  before :each do
    GiveBrand::MessageSender.any_instance.stub(:invitation_url).and_return('url')
  end

  it "can invite user from twitter" do
    invitation_message = create_invitation_message('twitter')
    GiveBrand::Client.should_receive(:new).with(inviter, 'twitter').and_return(client)

    message_body = "I've tagged you with \"rails\" on GiveBrand! Build your profile here: url"
    client.should_receive(:direct_message_create).with('pink_panter', message_body).and_return(true)

    receiver = GiveBrand::UserCreator.new(invitation_message, contact).create
    message_sender = GiveBrand::MessageSender.new(invitation_message, receiver, receiver_uid)
    message_sender.send_message
  end

  it "can invite user from linkedin" do
    invitation_message = create_invitation_message('linkedin')
    GiveBrand::Client.should_receive(:new).with(inviter, 'linkedin').and_return(client)

    message_subject = "Come build your profile at GiveBrand!"
    message_body = "I've tagged you with \"rails\" on GiveBrand! Start building your profile here: url"
    client.should_receive(:send_message).with(message_subject, message_body, [receiver_uid]).and_return(true)

    receiver = GiveBrand::UserCreator.new(invitation_message, contact).create
    message_sender = GiveBrand::MessageSender.new(invitation_message, receiver, receiver_uid)
    message_sender.send_message
  end

  it "can invite user from facebook" do
    invitation_message = create_invitation_message('facebook')

    message_subject = "Come claim your profile at GiveBrand!"
    message_body = "I've tagged you with \"rails\" on GiveBrand! Start building your profile here: url"

    receiver = GiveBrand::UserCreator.new(invitation_message, contact).create
    message_sender = GiveBrand::MessageSender.new(invitation_message, receiver, receiver_uid)
    message_sender.should_receive(:send_facebook_message).and_return(true)
    message_sender.send_message
  end
end
