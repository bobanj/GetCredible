class GiveBrand::Linkedin::Importer
  attr_accessor :authentication, :current_user, :client

  def initialize(authentication, client)
    @authentication = authentication
    @current_user = authentication.user
    @client = client
  end


  def import
    # In case we need to import contacts with pagination use:
    # client.connections({:start => 1, :count => 1}).total
    update_current_user

    connections.each do |connection|
      existing_authentication = Authentication.find_by_provider_and_uid('linkedin', connection.id)
      contact = create_contact(connection, existing_authentication)

      unless authentication.contacts.include?(contact)
        authentication.contacts << contact
      end

      if existing_authentication
        current_user.add_following(existing_authentication.user)
      end

    end
  end

  private

  def create_contact(connection, existing_authentication)
    contact = Contact.find_or_initialize_by_uid_and_provider(connection.id, 'linkedin')
    contact.attributes = {
        name:   "#{connection.first_name} #{connection.last_name}".strip,
        avatar: connection.picture_url,
        url:    connection.url.presence || connection.site_standard_profile_request.try(:url)
    }
    contact.user = existing_authentication.user if existing_authentication
    contact.save!
    contact
  end

  def update_current_user
    if current_user && !current_user.avatar?
      avatar = client.profile(:id => authentication.uid, fields: [:picture_url])
      current_user.remote_avatar_url = avatar.picture_url
      current_user.save
    end
  end

  def connections
    client.connections.all
  end

end
