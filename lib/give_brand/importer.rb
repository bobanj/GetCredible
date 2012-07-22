module GiveBrand
  module Importer
    def self.import(authentication)
      client = GiveBrand::Client.new(authentication.user, authentication.provider)

      case authentication.provider
        when 'twitter'
          importer = GiveBrand::Twitter::Importer.new(authentication, client)
          importer.import
        when 'linkedin'
          GiveBrand::Linkedin::Importer.import(authentication, client)
        when 'facebook'
          GiveBrand::Facebook::Importer.import(authentication, client)
      end
    end
  end
end
