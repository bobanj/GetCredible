class Gbrand::Twitter::Importer

  attr_accessor :current_user, :client, :users

  def self.import(current_user, client)
    current_user.twitter_handle = client.current_user.screen_name
    current_user.twitter_id = client.current_user.id
    current_user.save(validate: false)

    # fetch users
    importer = new(current_user, client)
    importer.fetch
    importer.save
  end

  def initialize(current_user, client)
    @current_user = current_user
    @client       = client
    @users        = []
  end

  def fetch
    cursor = -1

    while cursor != 0 do
      new_users = get_contacts(current_user.twitter_handle, cursor)
      @users    += new_users.users
      cursor    = new_users.next_cursor
    end
  end

  def save
    users.each do |user|
      unless current_user.followings.exists?(twitter_id: user.id)
        create_twitter_contact(user)
      end
    end
  end

  private

  def get_contacts(screen_name, cursor)
    cursor = client.get("/1/statuses/followers/#{screen_name}.json", {:cursor => cursor})
    Twitter::Cursor.new(cursor, 'users', Twitter::User)
  end

  def create_twitter_contact(user)
    twitter_contact = current_user.twitter_contacts.find_or_initialize_by_twitter_id(user.id)
    twitter_contact.attributes = {
      screen_name: user.screen_name.to_s.first(255),
      name: user.name.to_s.first(255),
      avatar: user.profile_image_url.to_s.first(255)
    }
    twitter_contact.save
  end
end

