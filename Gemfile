source 'https://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0'
gem 'responders'

# Caching
gem 'dalli'
###gem 'actionpack-action_caching'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'pg_search'

gem 'elasticsearch', git: 'git://github.com/elasticsearch/elasticsearch-ruby.git'

# Frontend frameworks
gem 'sprockets'
gem 'sprockets-rails'

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'sass'
gem 'bootstrap-sass'
gem 'autoprefixer-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
gem 'coffee-script'
gem 'coffee-script-source'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'execjs'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'newrelic_rpm'
gem 'puma'

# Application Specific
gem 'slim', github: 'einzige/slim'
gem 'slim-rails'
gem 'bcrypt', require: 'bcrypt'
gem 'rails_autolink'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'kramdown'

# Exception handling
gem 'rollbar'

# Play with time
gem 'chronic'

# Credit cards, billing, charges, payments
gem 'stripe', '1.31.0'
gem 'stripe-rails'

# Amazon S3
gem 'aws-sdk', '~> 2.0.48'

# Uploads, assets
gem 'transloadit-rails'

# Pagination
gem 'kaminari', github: 'amatsuda/kaminari'

# Markdown support
gem 'redcarpet'

# gem 'mailcatcher', group: :development

# Zip code validations
gem 'geokit'

# API to fetch bounce list
gem 'sendgrid-ruby'

group :development, :test do
  gem 'jazz_fingers'
  gem 'pry-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'guard-rspec', require: false
  gem 'guard-cucumber', require: false
  gem 'database_cleaner'
  gem 'stripe-ruby-mock', github: 'connectpal/stripe-ruby-mock', ref: 'b489c5f'
  gem 'timecop'
  gem 'cucumber-rails', require: false
  gem 'capybara-webkit'
  gem 'pry'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'
