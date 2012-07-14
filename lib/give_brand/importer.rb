module GiveBrand
  module Importer
    def self.import(authentication)
      case authentication.provider
        when 'twitter'
          GiveBrand::Twitter::Importer.import(authentication)
        when 'linkedin'
          GiveBrand::Linkedin::Importer.import(authentication)
        when 'facebook'
          GiveBrand::Facebook::Importer.import(authentication)
      end
    end
  end
end
