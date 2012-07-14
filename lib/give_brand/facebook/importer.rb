class GiveBrand::Facebook::Importer

  def self.import(authentication)
    client = GiveBrand::Facebook::Client.from_oauth_token(authentication.token)

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