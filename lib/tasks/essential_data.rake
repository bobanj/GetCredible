namespace :givebrand do
  # TODO Refactor Bobi
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
    tags = RandomWord.adjs.to_a[1..10].map { |word| {:name => word} }
    Tag.create tags
    tags = Tag.all

    puts "#########################"
    puts "Creating Users"
    num_users = 150
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
  end
end



