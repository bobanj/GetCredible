class ImportLinkedinContacts
  @queue = :high

  def self.perform(user_id)
    user = User.find user_id
    user.try(:import_linkedin_contacts)
  end

end