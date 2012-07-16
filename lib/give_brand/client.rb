module GiveBrand
  module Client
    def self.new(user, provider)
      authentication = user.send(:"#{provider}_authentication")
      case provider
        when 'twitter'
          GiveBrand::Twitter::Client.from_oauth_token(authentication.token, authentication.secret)
        when 'linkedin'
          GiveBrand::Linkedin::Client.from_oauth_token(authentication.token, authentication.secret)
        when 'facebook'
          GiveBrand::Facebook::Client.from_oauth_token(authentication.token)
      end
    end
  end
end
