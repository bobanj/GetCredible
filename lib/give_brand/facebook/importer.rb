class GiveBrand::Facebook::Importer

  def self.import(authentication, client)
    current_user = authentication.user
    if current_user && !current_user.avatar?
      me = client.fql_query("select pic from user where uid = me()")
      current_user.remote_avatar_url = me.first['pic']
      current_user.save
    end
    connections = client.fql_query("select uid, name, pic, profile_url from user where uid in (select uid2 from friend where uid1 = me())")
    connections.each do |connection|
      facebook_contact            = authentication.contacts.find_or_initialize_by_uid(connection['uid'].to_s)
      facebook_contact.attributes = {
          name:   connection['name'],
          avatar: connection['pic'],
          url:    connection['profile_url']
      }
      facebook_contact.save
    end
  end
end
