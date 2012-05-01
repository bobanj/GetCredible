namespace :get_credible do
  #TODO Refactor Bobi
  desc "Fill Redis Server For Existing Tags"
  task :fill_redis_tag => :environment do
    Tag.find_each do |t|
      t.save
    end
  end
end



