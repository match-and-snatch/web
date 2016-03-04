BuddyPlatform::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  #config.action_controller.asset_host = "//s3-us-west-1.amazonaws.com/buddy-assets"
  config.action_controller.asset_host = '//d37ecui9yfxlx3.cloudfront.net'

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'localhost', port: 1025 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  config.assets.digest = false
  config.assets.use_cdn = false
  config.assets.precompile += %w(ie.css underscore-min.js jquery.js)
  config.assets.paths << Rails.root.join('app', 'assets', 'images')
  config.stripe.secret_key = 'sk_test_onN61JMWKmncifVcCx8tsmGA'
end
