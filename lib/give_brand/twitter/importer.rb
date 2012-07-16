class GiveBrand::Twitter::Importer

  attr_accessor :current_user, :client, :users

  def self.import(authentication, client)
    current_user = authentication.user
    current_user.update_attribute(:twitter_handle, client.current_user.screen_name)

    # fetch users
    importer = new(current_user, client)
    importer.fetch_and_save
  end

  def initialize(current_user, client)
    @current_user = current_user
    @client       = client
  end

  def fetch_and_save
    fetch_users.each { |user| create_twitter_contact(user) }
  end

  def fetch_users
    users = []
    cursor = -1

    while cursor != 0 do
      new_users = get_contacts(current_user.twitter_handle, cursor)
      users     += new_users.users
      cursor    = new_users.next_cursor
    end

    users
  end

  private

  def get_contacts(screen_name, cursor)
    cursor = client.get("/1/statuses/followers/#{screen_name}.json", {:cursor => cursor})
    Twitter::Cursor.new(cursor, 'users', Twitter::User)
  end

  def create_twitter_contact(twitter_user)
    contact = current_user.twitter_authentication.contacts.find_or_initialize_by_uid(twitter_user.id.to_s)

    existing_authentication = Authentication.find_by_provider_and_uid('twitter', twitter_user.id.to_s)
    if existing_authentication
      current_user.add_following(existing_authentication.user)
      contact.user = existing_authentication.user
    end

    contact.attributes = {
      screen_name: twitter_user.screen_name.to_s.first(255),
      name: twitter_user.name.to_s.first(255),
      avatar: twitter_user.profile_image_url.to_s.first(255),
      url: "https://twitter.com/#{twitter_user.screen_name}"
    }

    contact.save
  end
end

