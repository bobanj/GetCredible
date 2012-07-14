class ImportContactsJob
  @queue = :import_contacts

  def self.perform(authentication_id)
    authentication = ::Authentication.find_by_id(authentication_id)
    if authentication
      case authentication.provider
        when 'twitter'
          client = Gbrand::Twitter::Client.from_oauth_token(authentication.token, authentication.secret)
          Gbrand::Twitter::Importer.import(authentication.user, client)
        when 'linkedin'
          client = Gbrand::Linkedin::Client.from_oauth_token(authentication.token, authentication.secret)

      end
    end
  end

end
