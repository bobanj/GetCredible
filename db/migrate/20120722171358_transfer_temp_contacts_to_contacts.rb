class TransferTempContactsToContacts < ActiveRecord::Migration
  def up
    User.order('id ASC').includes(:authentications).find_each do |user|
      puts "migrating contacts for user #{user.id}"
      user.authentications.each do |authentication|
        authentication.temp_contacts.find_each do |temp_contact|
          contact = Contact.find_or_initialize_by_uid_and_provider(temp_contact.uid, authentication.provider)
          contact.screen_name = temp_contact.screen_name
          contact.name = temp_contact.name
          contact.avatar = temp_contact.avatar
          contact.url = temp_contact.url
          contact.user_id = temp_contact.user_id
          contact.save!
          authentication.authentication_contacts.create!(invited: temp_contact.invited,
                                                        contact_id: contact.id)
        end
      end
    end
  end

  def down
    puts "irreversible migration"
  end
end
