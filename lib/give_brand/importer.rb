module GiveBrand
  module Importer
    def self.import(authentication)
      client = GiveBrand::Client.new(authentication.user, authentication.provider)

      importer = case authentication.provider
                   when 'twitter'
                     GiveBrand::Twitter::Importer.new(authentication, client)
                   when 'linkedin'
                     GiveBrand::Linkedin::Importer.new(authentication, client)
                   when 'facebook'
                     GiveBrand::Facebook::Importer.new(authentication, client)
                 end
      importer.import
    end
  end
end
