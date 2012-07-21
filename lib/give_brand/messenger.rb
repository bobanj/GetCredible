module GiveBrand
  class Messenger
    include Rails.application.routes.url_helpers

    attr_accessor :invitation_message, :sender, :receiver, :receiver_uid

    def initialize(invitation_message, receiver, receiver_uid)
      @invitation_message = invitation_message
      @sender             = invitation_message.inviter
      @receiver           = receiver
      @receiver_uid       = receiver_uid
    end

    def send_message
      case invitation_message.provider
      when 'twitter'
        client.direct_message_create(invitation_message.screen_name, message_body_short)
      when 'linkedin'
        client.send_message(message_subject, message_body, [receiver_uid])
      when 'facebook'
        send_facebook_message
      end
    end

    private
    def client
      @client ||= GiveBrand::Client.new(sender, invitation_message.provider)
    end

    def invitation_url
      invitation_message.view_context.accept_invitation_url(receiver,
          :invitation_token => receiver.invitation_token)
    end

    def message_body
      "I've tagged you with \"#{invitation_message.tag_names.join(', ')}\" on GiveBrand! Start building your profile here: #{invitation_url}"
    end

    def message_body_short
      "I've tagged you with \"#{invitation_message.tag_names.first}\" on GiveBrand! Start building your profile here: #{invitation_url}"
    end

    def message_subject
      "Come claim your profile at GiveBrand!"
    end

    def send_facebook_message
      facebook_auth    = sender.facebook_authentication
      sender_chat_id   = "-#{receiver_uid}@chat.facebook.com"
      receiver_chat_id = "-#{facebook_auth.uid}@chat.facebook.com"
      jabber_message   = Jabber::Message.new(sender_chat_id, message_body)
      jabber_message.subject = message_subject

      client = Jabber::Client.new Jabber::JID.new(receiver_chat_id)
      client.connect
      client.auth_sasl(Jabber::SASL::XFacebookPlatform.new(client,
         ENV.fetch('FACEBOOK_APP_ID'), facebook_auth.token,
         ENV.fetch('FACEBOOK_APP_SECRET')), nil)
      client.send(jabber_message)
      client.close
    end
  end
end
