class GiveBrand::Linkedin::Importer

  def self.import(authentication, client)
    # In case we need to import contacts with pagination use:
    # client.connections({:start => 1, :count => 1}).total

    current_user = authentication.user

    client.connections.all.each do |connection|
      contact = authentication.contacts.find_or_initialize_by_uid(connection.id)

      existing_authentication = Authentication.find_by_provider_and_uid('linkedin', connection.id)
      if existing_authentication
        current_user.add_following(existing_authentication.user)
        contact.user = existing_authentication.user
      end

      contact.attributes = {
          name:   "#{connection.first_name} #{connection.last_name}".strip,
          avatar: connection.picture_url,
          url:    connection.url
      }

      contact.save
    end
  end

end
