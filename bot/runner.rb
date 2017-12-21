require 'optparse'
require_relative 'bot'

options = {}
op = OptionParser.new
op.banner = 'Telegram bot for mpc'
op.on('-d', '--daemonize', 'run as daemon') { options[:daemonize] = true }
op.on('-p', '--pid PIDFILE', 'write PID to file') { |value| options[:pidfile] = value }
op.on('-l', '--log LOGFILE', 'write to log instead of stdout') { |value| options[:logfile] = value }
op.parse!

token = ENV['TOKEN']
unless token
  puts 'Provide bot token via env TOKEN!'
  exit 1
end

Process.daemon if options[:daemonize] # true - dont change working dir
File.write(options[:pidfile], Process.pid) if options[:pidfile]

logger = Logger.new(options[:logfile] || STDOUT)
bot = Bot.new(token, logger: logger)

begin
  bot.run
rescue => e
  logger.error(e)
  retry
end

File.delete(options[:pidfile]) if options[:pidfile]
