class GiveBrand::Linkedin::Importer

  def self.import(authentication)
    # In case we need to import contacts with pagination use:
    # client.connections({:start => 1, :count => 1}).total

    client = GiveBrand::Linkedin::Client.from_oauth_token(authentication.token, authentication.secret)

    client.connections.all.each do |connection|
      linkedin_contact            = authentication.contacts.find_or_initialize_by_uid(connection.id)
      linkedin_contact.attributes = {
          name:   "#{connection.first_name} #{connection.last_name}".strip,
          avatar: connection.picture_url,
          url:    connection.url
      }
      linkedin_contact.save
    end
  end

end