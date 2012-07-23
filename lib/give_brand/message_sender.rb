module GiveBrand
  class MessageSender
    class FacebookChatAccessDenied < StandardError; end

    include Rails.application.routes.url_helpers

    attr_accessor :invitation_message, :receiver, :receiver_uid
    delegate :inviter, :provider, :tag_names, :screen_name, :view_context,
             to: :invitation_message

    def initialize(invitation_message, receiver, receiver_uid)
      @invitation_message = invitation_message
      @receiver           = receiver
      @receiver_uid       = receiver_uid
    end

    def send_message
      case provider
      when 'twitter'
        client.direct_message_create(screen_name, message_body_short)
      when 'linkedin'
        client.send_message(message_subject, message_body, [receiver_uid])
      when 'facebook'
        send_facebook_message
      end
    end

    private
    def client
      @client ||= GiveBrand::Client.new(inviter, provider)
    end

    def invitation_url
      view_context.accept_invitation_url(receiver,
          :invitation_token => receiver.invitation_token)
    end

    def message_body
      "I've tagged you with \"#{tag_names.join(', ')}\" on GiveBrand! Start building your profile here: #{invitation_url}"
    end

    def message_body_short
      "I've tagged you with \"#{tag_names.first}\" on GiveBrand! Build your profile: #{invitation_url}"
    end

    def message_subject
      "Come build your profile at GiveBrand!"
    end

    def send_facebook_message
      facebook_auth    = inviter.facebook_authentication
      receiver_chat_id   = "-#{receiver_uid}@chat.facebook.com"
      sender_chat_id = "-#{facebook_auth.uid}@chat.facebook.com"
      jabber_message   = Jabber::Message.new(receiver_chat_id, message_body)
      jabber_message.subject = message_subject

      client = Jabber::Client.new(Jabber::JID.new(sender_chat_id))
      client.connect
      client.auth_sasl(Jabber::SASL::XFacebookPlatform.new(client,
         ENV.fetch('FACEBOOK_APP_ID'), facebook_auth.token,
         ENV.fetch('FACEBOOK_APP_SECRET')), nil)
      client.send(jabber_message)
      client.close
    rescue RuntimeError
      raise FacebookChatAccessDenied, "No access to Facebook Chat"
    end
  end
end
