namespace :givebrand do
  namespace :redis do

    task :clean => :environment do
      desc "Cleans redis data for Tag and UserTag"
      UserTag.find_each do |user_tag|
        Redis::Value.new("user_tag:#{user_tag.id}:incoming").delete
        Redis::Value.new("user_tag:#{user_tag.id}:outgoing").delete
        Redis::SortedSet.new("tag:#{user_tag.tag_id}:scores").delete(user_tag.id)
      end
    end

    task :purge => :environment do
      desc "Cleans all redis data"
      REDIS.keys.each {|k| REDIS.del(k) }
    end

    task :recalculate => :environment do
      desc "Recalculates the number of incoming and outgoing votes counters for user tag"
      UserTag.find_each do |user_tag|
        user_tag.update_counters
      end
    end

    task :autocomplete => :environment do
      desc "Makes tags available for autocomplete"
      Tag.find_each do |tag|
        tag.save
      end
    end
  end
end




