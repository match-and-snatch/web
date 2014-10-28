require 'resque/tasks'
task 'resque:setup' => :environment do
  Resque.before_fork = ActiveRecord::Base.establish_connection(ENV['HEROKU_POSTGRESQL_PINK_URL'])
end

