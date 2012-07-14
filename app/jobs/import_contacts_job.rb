class ImportContactsJob
  @queue = :import_contacts

  def self.perform(authentication_id)
    authentication = Authentication.find authentication_id
    if authentication
      case authentication.provider
        when 'twitter'
          ap "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
          client = Gbrand::Twitter::Client.from_oauth_token(authentication.token, authentication.secret)
          ap client
          Gbrand::Twitter::Importer.import(authentication.user, client)
        when 'linkedin'
      end
    end
  end

end