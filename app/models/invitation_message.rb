class InvitationMessage
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Validations::Callbacks
  extend ActiveModel::Naming

  # Attributes
  attr_accessor :view_context, :inviter, :uid, :provider, :name, :screen_name,
                :tag_names, :tag1, :tag2, :tag3

  # Callbacks
  before_validation :set_tag_names

  # Validations
  validates :inviter, presence: true
  validates :uid, presence: true
  validates :provider, inclusion: {in: ['twitter', 'facebook', 'linkedin']}
  validate :validate_at_least_one_tag

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    if valid?
      invite_contact
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

  def invite_contact
    User.transaction do
      invited = create_user
      GiveBrand::Messenger.new(self, invited, contact.uid).send_message
      contact.update_attributes({invited: true, user_id: invited.id})
    end
  end

  def create_user
    fake_email = "#{provider}_#{contact.uid}".downcase # devise saves email with downcase
    user = User.find_by_email(fake_email)
    unless user
      avatar = get_avatar_url(contact)
      user = User.new(email: fake_email, full_name: contact.name,
                      remote_avatar_url: avatar)
      user.invited_by = inviter
      user.skip_invitation = true
      user.invite!
    end
    inviter.add_tags(user, TagCleaner.clean(tag_names.join(',')), skip_email: true)
    inviter.add_following(user)
    user
  end

  def contact
    @contact ||= inviter.contacts.where(['provider = ?', provider]).find_by_uid!(uid)
  end

  def get_avatar_url(contact)
    if provider == 'twitter'
      # replace the last '_normal' with ''
      contact.avatar.to_s.reverse.sub('_normal'.reverse, '').reverse
    end
  end
end
