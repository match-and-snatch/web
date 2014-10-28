if ENV['REDISCLOUD_URL']
  uri = URI.parse(ENV['REDISCLOUD_URL'])
  Resque.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
else
  Resque.redis = Redis.new(host: 'pub-redis-12790.us-east-1-4.3.ec2.garantiadata.com',
                           port: 12790,
                           password: 'jJKJDmjSyaHEkBsL')
end

Resque.before_fork do
  ActiveRecord::Base.establish_connection(ENV['HEROKU_POSTGRESQL_PINK_URL'])
end

Resque.after_fork do
  ActiveRecord::Base.establish_connection(ENV['HEROKU_POSTGRESQL_PINK_URL'])
end