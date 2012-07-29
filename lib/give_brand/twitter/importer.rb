class GiveBrand::Twitter::Importer

  attr_accessor :authentication, :current_user, :client, :users

  def initialize(authentication, client)
    @authentication = authentication
    @current_user = authentication.user
    @client = client
  end

  def import
    update_current_user
    connections.each do |connection|
      existing_authentication = Authentication.find_by_provider_and_uid('twitter', connection.id.to_s)
      contact = create_contact(connection, existing_authentication)

      unless authentication.contacts.include?(contact)
        authentication.contacts << contact
      end

      if existing_authentication
        current_user.follow(existing_authentication.user)
      end

    end
  end

  private

  def update_current_user
    current_user.twitter_handle = client.current_user.screen_name
    if current_user && !current_user.avatar?
      avatar = client.current_user.profile_image_url_https.reverse.sub('_normal'.reverse, '').reverse
      current_user.remote_avatar_url = avatar
    end
    current_user.save
  end

  def connections
    users = []
    cursor = -1

    while cursor != 0 do
      new_users = get_contacts(cursor)
      users     += new_users.users
      cursor    = new_users.next_cursor
    end

    users
  end

  def get_contacts(cursor)
    cursor = client.get("/1/statuses/followers/#{current_user.twitter_handle}.json", {:cursor => cursor})
    Twitter::Cursor.new(cursor, 'users', Twitter::User)
  end

  def create_contact(connection, existing_authentication)
    contact = Contact.find_or_initialize_by_uid_and_provider(connection.id.to_s, 'twitter')
    contact.attributes = {
        screen_name: connection.screen_name.to_s.first(255),
        name: connection.name.to_s.first(255),
        avatar: connection.profile_image_url.to_s.first(255),
        url: "https://twitter.com/#{connection.screen_name}"
    }
    contact.user = existing_authentication.user if existing_authentication
    contact.save!
    contact
  end
end

