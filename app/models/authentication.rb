class Authentication < ActiveRecord::Base
  # Associations
  belongs_to :user

  # Validations
  validates :provider, presence: true
  validates :uid, presence: true
  validates :token, presence: true
  validates :secret, presence: true

  def import_contacts
    Resque.enqueue(ImportContactsJob, self.id)
  end

  def self.existing_users(contacts)
    where(["provider = 'twitter' AND uid IN (?)", contacts.map{|c| c.twitter_id.to_s}]).
      includes(:user).map(&:user)
  end
end
