namespace :get_credible do
  desc "Stats about GiveBrand users"
  task :stats => :environment do
    puts '------------------------------------------------'
    users_count = User.count
    puts "Total users: #{users_count}"

    contacts_count = Contact.count
    puts "Total contacts: #{contacts_count}"

    normal_registrations_count = User.where('invitation_sent_at IS NULL').count
    puts "Normal user registrations: #{normal_registrations_count}"

    invitations_sent_count = User.where('invitation_sent_at IS NOT NULL').count
    facebook_invitations_count = User.where("invitation_sent_at IS NOT NULL AND email LIKE 'facebook%'").count
    linkedin_invitations_count = User.where("invitation_sent_at IS NOT NULL AND email LIKE 'linkedin%'").count
    twitter_invitations_count  = User.where("invitation_sent_at IS NOT NULL AND email LIKE 'twitter%'").count
    email_invitations_count = invitations_sent_count - facebook_invitations_count - linkedin_invitations_count - twitter_invitations_count

    puts "Invitations sent: #{invitations_sent_count}"
    puts "  - facebook: #{facebook_invitations_count}"
    puts "  - linkedin: #{linkedin_invitations_count}"
    puts "  - twitter: #{twitter_invitations_count}"
    puts "  - email: #{email_invitations_count}"

    invitations_accepted = User.where('invitation_accepted_at IS NOT NULL').includes(:contact)
    puts "Invitations accepted: #{invitations_accepted.length}"
    invitations_accepted.group_by{|u| u.contact.try(:provider) }.each do |provider, contacts|
      puts "  - #{provider.presence || 'unknown'}: #{contacts.length}"
    end
    puts
    puts "* unknown - details lost because of db changes"
    puts '------------------------------------------------'
  end
end

