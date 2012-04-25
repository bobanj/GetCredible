require 'redis'
require 'redis/objects'
Redis.current = Redis::Namespace.new(:get_credible, :redis => Redis.new(:host => '127.0.0.1', :port => 6379))
