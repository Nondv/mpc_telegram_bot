# config valid only for current version of Capistrano
lock "3.7.1"

set :application, 'mpc_telegram_bot'
set :repo_url, 'git@github.com:Nondv/mpc_telegram_bot.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/pi/mpc_telegram_bot'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/config.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'tmp/pids', 'log'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  after(:finishing, 'bundle:install')
  after(:finishing, 'app:restart')
end

namespace :bundle do
  desc 'Run `bundle install`'
  task :install do
    on roles(:all) do |_host|
      within release_path do
        execute :bundle, 'install'
      end
    end
  end
end

namespace :app do
  desc 'Stop app'
  task :stop do
    on roles(:all) do |_host|
      within release_path do
        execute :bundle, 'exec rake stop'
      end
    end
  end

  desc 'Start app'
  task :start do
    on roles(:all) do |_host|
      within release_path do
        execute :bundle, 'exec rake start'
      end
    end
  end

  desc 'Restart app'
  task :restart do
    on roles(:all) do |_host|
      within release_path do
        execute :bundle, 'exec rake restart'
      end
    end
  end
end

namespace :logs do
  namespace :bot do
    desc 'View bot logs'
    task :tail, :lines do |_task, args|
      lines = args[:lines] || 25
      on roles(:all) do |_host|
        within release_path do
          execute "tail -#{lines} #{shared_path}/log/bot.log"
        end
      end
    end
  end
end
