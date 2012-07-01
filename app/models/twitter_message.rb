class TwitterMessage
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Validations::Callbacks
  extend ActiveModel::Naming
  include Rails.application.routes.url_helpers

  # Attributes
  attr_accessor :view_context, :inviter, :twitter_id, :screen_name,
                :tag_names, :tag1, :tag2, :tag3

  # Callbacks
  before_validation :set_tag_names

  # Validations
  validates_presence_of :inviter, :twitter_id, :screen_name
  validate :validate_at_least_one_tag

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    if valid?
      inviter_twitter_user
      true
    else
      false
    end
  end

  def persisted?
    false
  end

  private
  def set_tag_names
    self.tag_names = [tag1.presence, tag2.presence, tag3.presence].compact
  end

  def validate_at_least_one_tag
    errors[:tag1] << 'add at least one tag' if tag_names.blank?
  end

  def inviter_twitter_user
    User.transaction do
      invited = create_user
      inviter.followings << invited unless inviter.followings.exists?(invited)
      send_twitter_message(invited)
      twitter_contact.destroy
    end
  end

  def create_user
    fake_email = "twitter_#{twitter_contact.twitter_id}"
    user = User.find_by_email(fake_email)
    unless user
      avatar = get_avatar_url(twitter_contact)
      user = User.new(email: fake_email,
                      full_name: twitter_contact.name,
                      remote_avatar_url: avatar)
      user.twitter_id = twitter_contact.twitter_id
      user.invited_by = inviter
      user.skip_invitation = true
      user.invite!
    end
    inviter.add_tags(user, TagCleaner.clean(tag_names.join(',')), skip_email: true)
    inviter.add_following(user)
    user
  end

  def send_twitter_message(user)
    message = "I've tagged you with: #{tag_names.first} at GiveBrand!"
    url = view_context.accept_invitation_url(user,
                      :invitation_token => user.invitation_token)

    # make sure user receives invitation URL: 138 + char at 0 + ' ' = 140
    dm = "#{message[0..(138-url.length)]} #{url}"
    client.direct_message_create(screen_name, dm)
  end

  def client
    @client ||= Gbrand::Twitter::Client.from_oauth_token(
      inviter.twitter_token, inviter.twitter_secret)
  end

  def twitter_contact
    @twitter_contact||= @twitter_contact = inviter.twitter_contacts.
      find_by_twitter_id!(twitter_id)

  end

  def get_avatar_url(twitter_contact)
    # replace the last '_normal' with ''
    twitter_contact.avatar.reverse.sub('_normal'.reverse, '').reverse
  end
end
