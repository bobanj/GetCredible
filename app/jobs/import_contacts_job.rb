class ImportContactsJob
  @queue = :import_contacts

  def self.perform(authentication_id)
    authentication = Authentication.find_by_id(authentication_id)
    if authentication
      begin
        GiveBrand::Importer.import(authentication)
      ensure
        user = authentication.user
        user.update_attribute(:"#{authentication.provider}_state", 'finished')
      end
    end
  end

end
