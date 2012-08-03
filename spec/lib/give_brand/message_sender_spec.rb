# encoding: utf-8

require 'spec_helper'

describe GiveBrand::MessageSender do
  let(:inviter) { FactoryGirl.create(:user) }
  let(:contact) { FactoryGirl.create(:contact,
      uid: 'uid2', screen_name: 'pink_panter') }
  let(:receiver_uid) { 'uid1' }
  let(:client) { mock }
  let(:message_subject) { "message subject" }
  let(:message_body) { "message body" }

  def create_invitation_message(provider)
    InvitationMessage.new(tag_names: ['rails'],
      uid: 'uid2', provider: provider, screen_name: 'pink_panter', inviter: inviter)
  end

  before :each do
    GiveBrand::MessageSender.any_instance.stub(:invitation_url).and_return('url')
    GiveBrand::MessageSender.any_instance.stub(:message_subject).and_return(message_subject)
  end

  it "can invite user from twitter" do
    invitation_message = create_invitation_message('twitter')

    GiveBrand::Client.should_receive(:new).with(inviter, 'twitter').and_return(client)
    GiveBrand::MessageSender.any_instance.stub(:twitter_message).and_return(message_body)
    client.should_receive(:direct_message_create).with('pink_panter', message_body).and_return(true)

    receiver = GiveBrand::UserCreator.new(invitation_message, contact).create
    message_sender = GiveBrand::MessageSender.new(invitation_message, receiver, receiver_uid)
    message_sender.send_message
  end

  it "can invite user from linkedin" do
    invitation_message = create_invitation_message('linkedin')

    GiveBrand::Client.should_receive(:new).with(inviter, 'linkedin').and_return(client)
    GiveBrand::MessageSender.any_instance.stub(:linkedin_message).and_return(message_body)
    client.should_receive(:send_message).with(message_subject, message_body, [receiver_uid]).and_return(true)

    receiver = GiveBrand::UserCreator.new(invitation_message, contact).create
    message_sender = GiveBrand::MessageSender.new(invitation_message, receiver, receiver_uid)
    message_sender.send_message
  end

  it "can invite user from facebook" do
    invitation_message = create_invitation_message('facebook')

    GiveBrand::MessageSender.any_instance.stub(:facebook_message).and_return(message_body)

    receiver = GiveBrand::UserCreator.new(invitation_message, contact).create
    message_sender = GiveBrand::MessageSender.new(invitation_message, receiver, receiver_uid)
    message_sender.should_receive(:send_facebook_message).and_return(true)
    message_sender.send_message
  end
end
