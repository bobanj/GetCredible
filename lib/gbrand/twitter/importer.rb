class Gbrand::Twitter::Importer

  attr_accessor :current_user, :client, :contacts

  def self.import(current_user, client)
    # change current_user's twitter_handle in case he's logged in with other user
    current_user.update_attribute(:twitter_handle, client.current_user.screen_name)

    # fetch contacts
    importer = new(current_user, client)
    importer.fetch
    importer.save
  end

  def initialize(current_user, client)
    @current_user = current_user
    @client       = client
    @contacts     = []
  end

  def fetch
    cursor = -1

    while cursor != 0 do
      new_contacts = get_contacts(current_user.twitter_handle, cursor)
      @contacts    += new_contacts.users
      cursor       = new_contacts.next_cursor
    end
  end

  def save
    contacts.each { |contact| create_twitter_contact(contact) }
  end

  private

  def get_contacts(screen_name, cursor)
    cursor = client.get("/1/statuses/friends/#{screen_name}.json", {:cursor => cursor})
    Twitter::Cursor.new(cursor, 'users', Twitter::User)
  end

  def create_twitter_contact(user)
    twitter_contact = current_user.twitter_contacts.find_or_initialize_by_twitter_id(user.id)
    twitter_contact.meta_data = {
      twitter_id: user.id,
      screen_name: user.screen_name,
      name: user.name,
      avatar: user.profile_image_url
      # location: user.location,
      # description: user.description
      # url: user.url
    }
    twitter_contact.save!
  end
end

