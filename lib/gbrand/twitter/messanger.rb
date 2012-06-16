class Gbrand::Twitter::Messanger

  attr_accessor :twitter_contact, :client

  def initialize(twitter_contact, client)
    @twitter_contact = twitter_contact
    @client          = client
  end

  def create(params)
    client.direct_message_create(twitter_contact.screen_name, params[:message])
    twitter_contact.update_attribute(:invited, true)
  end
end
