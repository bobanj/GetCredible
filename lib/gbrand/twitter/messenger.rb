class Gbrand::Twitter::Messenger

  attr_accessor :twitter_contact, :client, :current_user, :params, :to

  def initialize(current_user, params)
    @current_user = current_user
    @params = params
    @client = Gbrand::Twitter::Client.from_oauth_token(
              current_user.twitter_token, current_user.twitter_secret)
    @twitter_contact = current_user.twitter_contacts.
                        find_by_twitter_id!(params[:twitter_id])
    @to = @twitter_contact.screen_name
  end

  def save
    return
    User.transaction do
      user = create_user_invitation
      current_user.followings << user unless current_user.followings.exists?(user)
      send_twitter_message(params, user)
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
      user.invited_by = current_user
      user.skip_invitation = true
      user.invite!
    end
    user
  end

  def send_twitter_message(params, user)
    # message = "#{params[:message]} #{accept_invitation_url(user, :invitation_token => user.invitation_token)}"
    # client.direct_message_create(to, message)
  end
end
