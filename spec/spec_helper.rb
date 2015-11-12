# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'
require 'stripe_mock'
require 'factories'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  config.run_all_when_everything_filtered = true
  config.filter_run focus: true

  config.include FactoryGirl::Syntax::Methods

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each, freeze: ->(value) { value.present? }) do |example|
    time = example.metadata[:freeze]
    time = case time
           when Time
             time
           when Date
             # We can't use Date#to_time because it doesn't account for timezones
             time.beginning_of_day
           when String
             Time.zone.parse(time)
           else
             # Current time rounded to seconds
             Time.zone.at(Time.now.to_i)
           end
    Timecop.freeze(time) { example.run }
  end
end

# @param index [String] index name
def refresh_index(name = '_all')
  Elasticpal::Client.refresh_index(name)
end

def update_index(*records)
  Elasticpal::Client.clear_data
  if records.any?
    records.each(&:elastic_index_document)
  else
    User.elastic_bulk_index
  end
  refresh_index
  yield if block_given?
end

# @param message [String, Symbol]
# @param opts [Hash]
# @return [String]
def t_error(message, opts = {})
  I18n.t message, opts.reverse_merge(scope: :errors, default: [:default, message])
end

# @param user [User]
# @return [Integer] user id
def sign_in(user = nil)
  user ||= create_user(email: 'email@gmail.com', password: 'password', password_confirmation: 'password')
  cookies.signed[:auth_token] = user.auth_token
end

def sign_in_with_token(token = nil)
  if token
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
end

def eager_load_app!
  unless @__eager_loaded
    Rails.application.eager_load!
    @__eager_loaded = true
  end
end

def enable_notifications!(&block)
  eager_load_app!
  Rails.application.config.notifications_enabled = true
  block.call.tap do
    Rails.application.config.notifications_enabled = false
  end
end
