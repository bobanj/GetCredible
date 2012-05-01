require 'redis'
require 'redis/objects'

uri = URI.parse(ENV["REDISTOGO_URL"])
#REDIS = $redis = Redis.current = Redis::Namespace.new('give_brand', :redis => Redis.new(:host => uri.host, :port => uri.port, :password => uri.password))
REDIS = $redis = Redis.current = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Soulmate::MIN_COMPLETE = 2
Soulmate.redis = ENV["REDISTOGO_URL"]