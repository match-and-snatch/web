source 'https://rubygems.org'
ruby '2.2.0'

# MZ - Adding font_assets
gem 'font_assets'
gem 'non-stupid-digest-assets'
gem 'font-awesome-rails'
gem 'font-awesome-sass', '~> 4.3.0'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.7.14'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
gem 'pg'
gem 'pg_search'

# Assets
gem 'sass-rails', '~> 5.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Web server
gem 'puma'

# Templates
gem 'slim-rails'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'bootstrap-sass'

# Background jobs
gem 'daemons'
gem 'delayed_job_active_record'

# Credit cards, billing, charges, payments
gem 'stripe-rails'

gem 'mailcatcher', group: :development

group :development, :test do
  gem 'awesome_print'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'database_cleaner', github: 'bmabey/database_cleaner'
  gem 'stripe-ruby-mock', '~> 1.10.1.7'
  gem 'timecop'
end
