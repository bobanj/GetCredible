require 'redis'
require 'redis/objects'

if(Rails.env.production?)
  redis_url = 'redis://redistogo:9883ab2d8a51f29a335f3256ac4a9c1d@drum.redistogo.com:9223/'
else
  redis_url = 'redis://127.0.0.1:6379'
end
uri = URI.parse(redis_url)
Redis.current = Redis::Namespace.new('give_brand', :redis => Redis.new(:host => uri.host, :port => uri.port, :password => uri.password))
