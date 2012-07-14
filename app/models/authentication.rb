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
end
