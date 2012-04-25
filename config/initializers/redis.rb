require 'redis'
require 'redis/objects'

uri = URI.parse(Settings.redis.url)
Redis.current = Redis::Namespace.new(Settings.redis.namespace, :redis => Redis.new(:host => uri.host, :port => uri.port))
