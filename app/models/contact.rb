class Contact < ActiveRecord::Base

  # Attributes
  attr_accessible :user_id, :avatar, :name, :uid, :url, :screen_name

  # Associations
  has_many :authentication_contacts
  belongs_to :user

  # Validations
  validates :uid, presence: true
  validates :provider, presence: true
  validates :screen_name, length: {maximum: 255}
  validates :name, length: {maximum: 255}
  validates :avatar, length: {maximum: 255}

  # Scopes
  scope :ordered, order('name ASC')

  def twitter?
    provider == 'twitter'
  end

  def linkedin?
    provider == 'linkedin'
  end

  def facebook?
    provider == 'facebook'
  end

end
