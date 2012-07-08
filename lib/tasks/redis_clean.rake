namespace :givebrand do
  #TODO Refactor Bobi
  namespace :redis do

    task :clean => :environment do
      desc "Cleans redis data for Tag and UserTag"
      UserTag.find_each do |ut|
        Redis::Value.new("user_tag:#{ut.id}:incoming").delete
        Redis::Value.new("user_tag:#{ut.id}:outgoing").delete
        Redis::SortedSet.new("tag:#{ut.tag_id}:scores").delete(ut.id)
      end
    end

    task :recalculate => :environment do
      desc "Recalculates the number of incoming and outgoing votes counters for user tag"
      UserTag.find_each do |ut|
        ut.update_counters
      end
    end

    task :autocomplete => :environment do
      desc "Makes tags available for autocomplete"
      Tag.find_each do |t|
        t.save
      end
    end

  end
end




