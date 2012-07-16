module GiveBrand::Twitter::Client
  def self.from_oauth_token(oauth_token, oauth_token_secret)
    Twitter.configure do |config|
      config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token        = oauth_token
      config.oauth_token_secret = oauth_token_secret
    end
    Twitter::Client.new
  end
end
