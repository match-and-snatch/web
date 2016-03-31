module BuddyPlatform
  module Database
    def connect(size = 32)
      config = Rails.application.config.database_configuration[Rails.env]
      config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
      config['pool']              = ENV['DB_POOL']      || size
      ActiveRecord::Base.establish_connection(config)
    end

    def disconnect
      ActiveRecord::Base.connection_pool.disconnect!
    end

    def reconnect(size)
      disconnect
      connect(size)
    end

    module_function :disconnect, :connect, :reconnect
  end
end

Rails.application.config.after_initialize do
  BuddyPlatform::Database.disconnect

  ActiveSupport.on_load(:active_record) do
    if Puma.respond_to?(:cli_config)
      size = Puma.cli_config.options.fetch(:max_threads)
      BuddyPlatform::Database.reconnect(size)
    else
      BuddyPlatform::Database.connect
    end
  end
end
