# encoding: utf-8

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
        client.direct_message_create(screen_name, twitter_message)
      when 'linkedin'
        client.send_message(message_subject, linkedin_message, [receiver_uid])
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

    def message_subject
      "#{invitation_message.inviter.name} has invited you to create a GiveBrand profile"
    end

    def send_facebook_message
      facebook_auth    = inviter.facebook_authentication
      receiver_chat_id   = "-#{receiver_uid}@chat.facebook.com"
      sender_chat_id = "-#{facebook_auth.uid}@chat.facebook.com"
      jabber_message   = Jabber::Message.new(receiver_chat_id, facebook_message)
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

    def linkedin_message
      "Dear #{receiver.name}:
      I'm building my personal brand on http://givebrand.com, a website that lets jobseekers and other professionals invite their friends and colleagues to weigh in on their best attributes.\n
      My profile is an easy-to-understand visual snapshot of my skills and traits that I'll be able to share with clients, hiring managers and other professional contacts.\n
      I thought you might like to sign up for your own profile: #{invitation_url}. To get you started, I've tagged you with \"#{tag_names.join(', ')}\".\n
      See you on http://givebrand.com!"
    end

    def facebook_message
      "I'm building my personal brand on http://givebrand.com, a website that puts a social spin on my résumé by letting me invite my friends and colleagues to weigh in on my best attributes.\n
      They're helping me create an easy-to-understand visual snapshot of my skills and traits that I'll be able to share with clients, hiring managers and other professional contacts.\n
      I thought you might like to sign up for your own profile: #{invitation_url}. I've tagged you with \"#{tag_names.join(', ')}\" to get you started. Please join me!\n
      See you there."
    end

    def twitter_message
      tag = tag_names.first.to_s.first(22)
      "Put a social twist on your résumé on @GiveBrand! I tagged you w/ \"#{tag}\" to get you started — try it! #{invitation_url}"
    end
  end
end
