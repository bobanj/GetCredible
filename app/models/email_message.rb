class EmailMessage
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Validations::Callbacks
  extend ActiveModel::Naming

  # Attributes
  attr_accessor :email, :invited, :tag_names, :tag1, :tag2, :tag3

  # Callbacks
  before_validation :set_tag_names

  # Validations
  validates_presence_of :email
  validate :validate_at_least_one_tag

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save(inviter)
    if valid?
      invited = User.invite!({email: email, tag_names: tag_names}, inviter)
      inviter.add_tags(invited, TagCleaner.clean(tag_names), skip_email: true)
      inviter.followings << invited unless inviter.followings.exists?(invited)
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
end
