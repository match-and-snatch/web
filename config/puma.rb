threads 4,12
workers 2
preload_app!
on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end
on_restart do
  ActiveRecord::Base.connection_pool.disconnect!
end
on_worker_shutdown do
  ActiveRecord::Base.connection_pool.disconnect!
end
