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
      num_users = 500
      num_users.times do |index|
        u = User.new
        u.full_name = "populator_#{index}"
        u.password = "populator"
        u.email = "populator_#{index}@givebrand.to"
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

      (1..5).each do |page|
        puts "#############################"
        puts page
        users = User.paginate :per_page => 100, :page => page
        users.each do |user|
          votes_to_be_given = num_votes_per_page(page)
          voters = User.limit(votes_to_be_given + 1)
          voters.each do |voter|
            user.user_tags.each do |user_tag|
              voter.vote_exclusively_for(user_tag)
            end
          end
        end
      end
    end

    def range_rand(min, max)
      min + rand(max-min)
    end

    def num_votes_per_page(page)
      case page
        when 1
          range_rand(10, 15)
        when 2
          range_rand(100, 130)
        when 3
          range_rand(200, 300)
        when 4
          range_rand(300, 400)
        when 5
          range_rand(490, 500)
        else
          range_rand(30, 100)
      end
    end

  end
end



