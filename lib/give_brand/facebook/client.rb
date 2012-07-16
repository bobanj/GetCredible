module GiveBrand::Facebook::Client
  def self.from_oauth_token(oauth_token)
    Koala::Facebook::API.new(oauth_token)
  end
end
