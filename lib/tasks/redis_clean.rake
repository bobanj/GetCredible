namespace :get_credible do
  #TODO Refactor Bobi
  desc "Fill Redis Server For Existing Tags"
  task :redis_clean => :environment do
    UserTag.all.each do |ut|
      Redis::Value.new("user_tag:#{ut.id}:incoming").delete
      Redis::Value.new("user_tag:#{ut.id}:outgoing").delete
      Redis::SortedSet.new("tag:#{ut.tag_id}:scores").delete(ut.id)
    end
  end
end




