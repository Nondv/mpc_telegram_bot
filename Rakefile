require_relative 'config/config_wrapper'

def bot_pid
  File.exist?(Config.bot_pid_file) && File.read(Config.bot_pid_file).to_i
end

def kill_process(pid)
  Rake.rake_output_message "KILL #{pid}"
  Process.kill(9, pid)
  true
rescue Errno::ESRCH
  # No such process
  false
end

desc 'Start bot daemon'
task :start do
  Rake::Task['bot:daemon:start'].invoke
end

desc 'Stop bot daemon'
task :stop do
  Rake::Task['bot:daemon:stop'].invoke
end

desc 'Restart bot daemon'
task :restart do
  Rake::Task['bot:daemon:restart'].invoke
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
      kill_process(bot_pid)    if bot_pid
      rm(Config.bot_pid_file)  if File.exist?(Config.bot_pid_file)
    end

    desc 'Restart (or just start) Telegram bot daemon'
    task :restart do
      Rake::Task['bot:daemon:stop'].invoke
      Rake::Task['bot:daemon:start'].invoke
    end
  end
end
