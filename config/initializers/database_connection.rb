module BuddyPlatform
  module Database
    def connect(size = nil)
      config = Rails.application.config.database_configuration[Rails.env]
      config['pool'] = size if size
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
    size = Puma.cli_config.options.fetch(:max_threads) if Puma.respond_to?(:cli_config)
    BuddyPlatform::Database.reconnect(size)
  end
end
