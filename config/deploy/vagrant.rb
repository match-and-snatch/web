set :ssh_options, {
  forward_agent: true,
}

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
