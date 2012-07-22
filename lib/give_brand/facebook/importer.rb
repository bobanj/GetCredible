class GiveBrand::Facebook::Importer

  def self.import(authentication, client)
    current_user = authentication.user
    update_current_user(current_user)

    connections = client.fql_query("select uid, name, pic, profile_url from user where uid in (select uid2 from friend where uid1 = me())")
    connections.each do |connection|
      existing_authentication = Authentication.find_by_provider_and_uid('facebook', connection['uid'].to_s)
      contact = create_contact(connection, existing_authentication)

      unless authentication.contacts.include?(contact)
        authentication.contacts << contact
      end

      if existing_authentication
        current_user.add_following(existing_authentication.user)
      end

      contact.save
    end
  end

  private
  def self.create_contact(connection, existing_authentication)
    contact = Contact.find_or_initialize_by_uid_and_provider(connection['uid'].to_s, 'facebook')
    contact.attributes = {
        name:   connection['name'],
        avatar: connection['pic'],
        url:    connection['profile_url']
    }
    contact.user = existing_authentication.user if existing_authentication
    contact.save!
    contact
  end

  def self.update_current_user(current_user)
    if current_user && !current_user.avatar?
      me = client.fql_query("select pic from user where uid = me()")
      current_user.remote_avatar_url = me.first['pic']
      current_user.save
    end
  end
end
