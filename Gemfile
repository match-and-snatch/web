source 'https://rubygems.org'
ruby '2.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.0'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'pg_search'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Required by Heroku
gem 'rails_12factor', group: :production
gem 'unicorn'
gem 'foreman', group: :development
gem 'newrelic_rpm'

# Application Specific
gem 'slim-rails'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'bootstrap-sass'
gem 'resque', '~> 1.22.0'
gem 'rails_autolink'

# Credit cards, billing, charges, payments
gem 'stripe-rails'

# Uploads, assets
gem 'transloadit-rails'

gem 'mailcatcher', group: :development

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'guard-rspec', require: false
  gem 'awesome_print'
end

group :test do
  gem 'database_cleaner', github: 'bmabey/database_cleaner'
  gem 'stripe-ruby-mock', '~> 1.10.1.7'
  gem 'timecop'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
#
