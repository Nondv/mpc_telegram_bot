require 'rake/testtask'
require_relative 'config_wrapper'

config = YAML.load(File.read('config.yml'))

def api_pid
  File.exist?(Config.api_pid_file) && File.read(Config.api_pid_file)
end

def bot_pid
  File.exist?(Config.bot_pid_file) && File.read(Config.bot_pid_file)
end

desc 'Start api and bot daemons'
task :start do
  Rake::Task['api:daemon:start'].invoke
  Rake::Task['bot:daemon:start'].invoke
end

desc 'Stop api and bot daemons'
task :stop do
  Rake::Task['api:daemon:stop'].invoke
  Rake::Task['bot:daemon:stop'].invoke
end

desc 'Restart api and bot daemons'
task :restart do
  Rake::Task['api:daemon:restart'].invoke
  Rake::Task['bot:daemon:restart'].invoke
end

namespace :api do
  desc 'Start api server'
  task :start do
    sh "rackup -p #{Config.api_port}"
  end

  namespace :daemon do
    desc 'Start api server as daemon'
    task :start do
      !api_pid && sh("rackup -p #{Config.api_port} -D -P #{Config.api_pid_file}")
    end

    desc 'Stop api server daemon'
    task :stop do
      next unless api_pid
      sh("kill -QUIT #{api_pid}")
      rm(Config.api_pid_file)
    end

    desc 'Restart (or just start) api server daemon'
    task :restart do
      Rake::Task['api:daemon:stop'].invoke
      Rake::Task['api:daemon:start'].invoke
    end
  end
end

namespace :bot do
  desc 'Start Telegram bot'
  task :start do
    ruby 'bot/runner.rb'
  end

  namespace :daemon do
    desc 'Start Telegram bot as daemon'
    task :start do
      !bot_pid && ruby("bot/runner.rb -d -p #{Config.bot_pid_file} -l #{Config.bot_log_file}")
    end

    desc 'Stop Telegram bot daemon'
    task :stop do
      next unless bot_pid
      sh("kill -KILL #{bot_pid}")
      rm(Config.bot_pid_file)
    end

    desc 'Restart (or just start) Telegram bot daemon'
    task :restart do
      Rake::Task['bot:daemon:stop'].invoke
      Rake::Task['bot:daemon:start'].invoke
    end
  end
end

Rake::TestTask.new do |t|
  ENV['RACK_ENV'] = 'test'
  # t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
