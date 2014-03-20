# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'vagrant'
set :repository,  '.'

role :web, 'vagrant'

set :use_sudo, false
set :user, 'vagrant'
set :run_method, :sudo
set :release_path, '/vagrant'

namespace :server do
  desc 'Runs app server'
  task :start do
    on roles(:web) do
      within release_path do
        execute "bash -cl 'cd #{release_path} && foreman start'"
      end
    end
  end

  desc 'Restarts app installing all the things you need'
  task :restart do
    on roles(:web) do
      within release_path do
        execute "bash -cl 'cd #{release_path} && foreman run bundle install && foreman run rake db:migrate && foreman start'"
      end
    end
  end

  desc 'Stops web app server'
  task :stop do
    on roles(:web) do
      within release_path do
        if File.exists?('.server_pid')
          pid = File.read('.server_pid').to_i
          execute "kill -9 #{pid} && echo 'success' || echo 'failed'"
        end
      end
    end
  end

  before :start, :stop
  before :restart, :stop
end

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

#namespace :deploy do
#
#  desc 'Restart application'
#  task :restart do
#    on roles(:app), in: :sequence, wait: 5 do
#      # Your restart mechanism here, for example:
#      # execute :touch, release_path.join('tmp/restart.txt')
#    end
#  end
#
#  after :publishing, :restart
#
#  after :restart, :clear_cache do
#    on roles(:web), in: :groups, limit: 3, wait: 10 do
#      # Here we can do anything such as:
#      # within release_path do
#      #   execute :rake, 'cache:clear'
#      # end
#    end
#  end
#
#end
