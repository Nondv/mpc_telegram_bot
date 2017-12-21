require 'optparse'
require_relative 'bot'

options = {}
op = OptionParser.new
op.banner = 'Telegram bot for mpc'
op.on('-l', '--log LOGFILE', 'write to log instead of stdout') { |value| options[:logfile] = value }
op.on('-t', '--token TOKEN', 'telegram token') { |value| options[:token] = value }
op.parse!

token = options[:token] || ENV['TOKEN']
unless token
  puts 'Provide bot token via env TOKEN or --token option!'
  exit 1
end

logger = Logger.new(options[:logfile] || STDOUT)
bot = Bot.new(token, logger: logger)

begin
  bot.run
rescue => e
  logger.error(e)
  retry
end
