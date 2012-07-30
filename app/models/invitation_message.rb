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
      save_and_invite
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

  def save_and_invite
    User.transaction do
      user = GiveBrand::UserCreator.new(self, contact).create
      GiveBrand::MessageSender.new(self, user, contact.uid).send_message
      contact.update_column(:user_id, user.id)
      ac = inviter.authentication_contacts.find_by_contact_id!(contact.id)
      ac.update_column(:invited, true)
    end
  end

  def contact
    @contact ||= inviter.contacts.where(['contacts.provider = ?', provider]).find_by_uid!(uid)
  end
end
