class Authentication < ActiveRecord::Base
  # Associations
  belongs_to :user

  def import_contacts
    Resque.enqueue(ImportContactsJob, self.id)
  end
end
