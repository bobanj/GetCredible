class Authentication < ActiveRecord::Base
  # Attributes
  attr_accessible :provider, :uid, :token, :secret

  # Associations
  belongs_to :user
  has_many :contacts, dependent: :destroy

  # Validations
  validates :user_id, presence: true
  validates :provider, presence: true
  validates :uid, presence: true
  validates :token, presence: true

  def import_contacts
    Resque.enqueue(ImportContactsJob, self.id)
  end

  def self.existing_users(contacts)
    where(["provider = 'twitter' AND uid IN (?)", contacts.map(&:uid)]).
      includes(:user).map(&:user)
  end
end
