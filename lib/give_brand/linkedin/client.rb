module GiveBrand::Linkedin::Client
  def self.from_oauth_token(oauth_token, oauth_token_secret)
    client = LinkedIn::Client.new(ENV['LINKEDIN_CONSUMER_KEY'], ENV['LINKEDIN_CONSUMER_SECRET'])
    client.authorize_from_access(oauth_token, oauth_token_secret)
    client
  end
end
