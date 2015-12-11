source 'https://rubygems.org'
ruby '2.2.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
gem 'responders', '~> 2.1'

# Caching
gem 'dalli'
gem 'actionpack-action_caching'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'pg_search', '~> 1.0.5'

gem 'elasticsearch', git: 'git://github.com/elasticsearch/elasticsearch-ruby.git'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.5'
gem 'sprockets', '2.12.4'
gem 'sprockets-rails', '2.3.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.3.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'newrelic_rpm'
gem 'puma'

# Application Specific
gem 'slim', github: 'einzige/slim'
gem 'slim-rails'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'bootstrap-sass'
gem 'rails_autolink'
gem 'daemons'
gem 'delayed_job_active_record'

# Exception handling
gem 'rollbar', '~> 2.6.3'

# Play with time
gem 'chronic'

# Credit cards, billing, charges, payments
gem 'stripe', '1.31.0'
gem 'stripe-rails'

# Amazon S3
gem 'aws-sdk', '~> 2.2.4'

# Uploads, assets
gem 'transloadit-rails'

# Pagination
gem 'kaminari', github: 'amatsuda/kaminari'

gem 'mailcatcher', group: :development

group :development, :test do
  gem 'jazz_fingers'
  gem 'pry-rails'
  gem "factory_girl_rails", "~> 4.5.0"
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'guard-rspec', require: false
  gem 'guard-cucumber', require: false
  gem 'database_cleaner', github: 'bmabey/database_cleaner'
  gem 'stripe-ruby-mock'
  gem 'timecop'
  gem 'cucumber-rails', require: false
  gem 'capybara-webkit'
  gem 'pry'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]
#
