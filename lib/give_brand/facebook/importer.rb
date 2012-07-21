class GiveBrand::Facebook::Importer

  def self.import(authentication, client)
    current_user = authentication.user
    update_current_user(current_user)

    connections = client.fql_query("select uid, name, pic, profile_url from user where uid in (select uid2 from friend where uid1 = me())")
    connections.each do |connection|
      contact            = authentication.contacts.find_or_initialize_by_uid(connection['uid'].to_s)

      existing_authentication = Authentication.find_by_provider_and_uid('facebook', connection['uid'].to_s)
      if existing_authentication
        current_user.add_following(existing_authentication.user)
        contact.user = existing_authentication.user
      end

      contact.attributes = {
          name:   connection['name'],
          avatar: connection['pic'],
          url:    connection['profile_url']
      }
      contact.save
    end
  end

  private
  def self.update_current_user(current_user)
    if current_user && !current_user.avatar?
      me = client.fql_query("select pic from user where uid = me()")
      current_user.remote_avatar_url = me.first['pic']
      current_user.save
    end
  end
end
