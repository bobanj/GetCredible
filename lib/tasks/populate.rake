namespace :get_credible do
  namespace :db do
    desc "Populate database with fake data(development only)"
    task :populate => :environment do
      desc "Populates db"
      puts "####### POPULATOR STARTED #########"
      if Rails.env.production?
        puts "####### One does not simply populate production env !!! #########"
        exit
      end
      puts "#########################"
      puts "Destroying All"
      User.destroy_all
      Tag.destroy_all
      Vote.destroy_all

      puts "Truncating tables....because we want clean stuff"
      [ActivityItem, Authentication, Tag, User, UserTag, Vote].each do |c|
        ActiveRecord::Base.connection.execute("TRUNCATE #{c.table_name}")
        case ActiveRecord::Base.connection.adapter_name
          when 'PostgreSQL'
            ActiveRecord::Base.connection.reset_pk_sequence!(c.table_name)
        end

      end

      puts "#########################"
      puts "Creating Tags"
      tags = RandomWord.adjs.to_a[1..2].map { |word| {:name => word} }
      Tag.create tags
      tags = Tag.all

      puts "#########################"
      puts "Creating Users"
      num_users = 250
      num_users.times do |index|
        u = User.new
        u.full_name = "populator_#{index + 1}"
        u.password = "populator"
        u.email = "populator_#{index + 1}@givebrand.to"
        u.save
      end

      puts "#########################"
      puts "Assigning Tags to Users"
      #num_tags_per_user = 2

      User.all.each do |user|
        #random_tag_ids = []
        random_tagger_id = rand(num_users)+1
        loop do
          break if random_tagger_id != user.id
          random_tagger_id = rand(num_users)+1
        end
        random_tagger = User.find random_tagger_id
        #loop do
        #random_tag_id = rand(Tag.count)+1
        #random_tag_ids << random_tag_id unless random_tag_ids.include?(random_tag_id)
        #random_tag_ids.uniq!
        #break if random_tag_ids.size >= num_tags_per_user
        #end
        tags.each do |tag|
          user.user_tags.create(:tagger => random_tagger, :tag => tag)
        end
      end

      first_50 = User.includes(:user_tags).paginate :per_page => 50, :page => 1
      second_50 = User.includes(:user_tags).paginate :per_page => 50, :page => 2
      #third_50 = User.paginate :per_page => 50, :page => 3
      #forth_50 = User.paginate :per_page => 50, :page => 4

      first_50.each do |voter|
        second_50.each do |user|
          first_tag = user.user_tags.order('asc').first
          second_tag = user.user_tags.order('asc').last
          puts "@@@@@@@@@@@@@@@@@@@@@@"
          p "#{voter.id} => #{first_tag.id}"
          p "#{voter.id} => #{second_tag.id}"
          puts "@@@@@@@@@@@@@@@@@@@@@@"
          voter.vote_exclusively_for(first_tag)
          voter.vote_exclusively_for(second_tag)
        end
      end

      second_50.each do |voter|
        first_50.each do |user|
          first_tag = user.user_tags.order('asc').first
          second_tag = user.user_tags.order('asc').last
          puts "@@@@@@@@@@@@@@@@@@@@@@"
          p "#{voter.id} => #{first_tag.id}"
          p "#{voter.id} => #{second_tag.id}"
          puts "@@@@@@@@@@@@@@@@@@@@@@"
          voter.vote_exclusively_for(first_tag)
          voter.vote_exclusively_for(second_tag)
        end
      end
    #
    #  (1..4).each do |page|
    #    puts "#############################"
    #    puts page
    #    users = User.includes(:user_tags).paginate :per_page => 50, :page => page
    #
    #    users.each_with_index do |user, index|
    #      puts "@@@@@@@@@@@@@@@@@@@@@@"
    #      p "page => #{page},  index => #{index}"
    #      puts "@@@@@@@@@@@@@@@@@@@@@@"
    #      votes_to_be_given = num_votes_per_page(page)
    #      while votes_to_be_given > 0
    #        voter = first_50[rand(49) + 1]
    #        voter.vote_exclusively_for(user.user_tags.first)
    #        voter.vote_exclusively_for(user.user_tags.last)
    #        votes_to_be_given -= 1
    #      end
    #    end
    #  end

    end

    def range_rand(min, max)
      min + rand(max-min)
    end

    def num_votes_per_page(page)
      case page
        when 1
          range_rand(10, 15)
        when 2
          range_rand(50, 70)
        when 3
          range_rand(70, 100)
        when 4
          range_rand(100, 150)
        when 5
          range_rand(200, 240)
        else
          range_rand(30, 100)
      end
    end

  end
end



