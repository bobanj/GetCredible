namespace :get_credible do
  #TODO Refactor Bobi
  desc "Populate database with fake data(development only)"
  task :vote => :environment do
    desc "Vote db"
    puts "####### POPULATOR STARTED #########"
    if Rails.env.production?
      puts "####### One does not simply populate production env !!! #########"
      exit
    end
    puts "#########################"
    puts "Destroying All Votes"
    Vote.destroy_all

    puts "Truncating Votes"
    [Vote].each do |c|
      ActiveRecord::Base.connection.execute("TRUNCATE #{c.table_name}")
      case ActiveRecord::Base.connection.adapter_name
        when 'PostgreSQL'
          ActiveRecord::Base.connection.reset_pk_sequence!(c.table_name)
      end
    end

    puts "Creating Super User"
    superuser = User.first
    supertag = superuser.user_tags.order("id asc").first
    User.where("id != ?", superuser.id).each do |user|
      user.vote_exclusively_for(supertag)
    end

    num_random_votes = 5000
    puts "Creating #{num_random_votes} Random Votes"
    num_random_votes.times do |i|
      random_voter = User.find_by_id (rand(User.count) + 1) rescue nil
      if random_voter
        random_user_tag = UserTag.find_by_id(range_rand(1,100)) rescue nil
        if random_user_tag
          random_voter.vote_exclusively_for(random_user_tag)
        end
      end
    end


  end

  def range_rand(min, max)
    min + rand(max-min)
  end
end



