require 'redis'
require 'mock_redis' if Rails.env.test?

if Rails.env.test?
  $redis = MockRedis.new
else
  $redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
end 