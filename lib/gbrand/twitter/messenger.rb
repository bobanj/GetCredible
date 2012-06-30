class Gbrand::Twitter::Messenger

  attr_accessor :twitter_contact, :client, :inviter, :message

  def initialize(message, inviter)
    @message = message
    @inviter = inviter
    @client  = Gbrand::Twitter::Client.from_oauth_token(
               inviter.twitter_token, inviter.twitter_secret)
    @twitter_contact = inviter.twitter_contacts.
                        find_by_twitter_id!(message.twitter_id)
  end

  def save
    return
    User.transaction do
      user = create_user_invitation
      inviter.followings << user unless inviter.followings.exists?(user)
      send_twitter_message(message, user)
      twitter_contact.destroy
    end
  end

  private
  def create_user_invitation
    fake_email = "twitter_#{twitter_contact.twitter_id}"
    user = User.find_by_email(fake_email)
    unless user
      user = User.new(email: fake_email, full_name: twitter_contact.name,
                      avatar: twitter_contact.avatar)
      user.twitter_id = twitter_contact.twitter_id
      user.invited_by = inviter
      user.skip_invitation = true
      user.invite!
    end
    user
  end

  def send_twitter_message(message, user)
    # message = "I've tagged you with #{message.tag_names.join(', ')} at GiveBrand! #{accept_invitation_url(user, :invitation_token => user.invitation_token)}"
    # client.direct_message_create(message.screen_name, message)
  end
end
