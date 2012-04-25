require 'redis'
require 'redis/objects'

uri = URI.parse(Settings.redis.url)
Redis.current = Redis::Namespace.new(:get_credible, :redis => Redis.new(:host => uri.host, :port => uri.port))
