require 'optparse'
require_relative 'bot'

options = {
  mpd_host: 'localhost'
}
op = OptionParser.new
op.banner = 'Telegram bot for mpc'
op.on('-l', '--log LOGFILE', 'write to log instead of stdout') { |value| options[:logfile] = value }
op.on('-t', '--token TOKEN', 'telegram token') { |value| options[:token] = value }
op.on('-m', '--mpd-host HOST', "MPD host. Default is #{options[:mpd_host]}") { |value| options[:mpd_host] = value }
op.parse!

token = options[:token] || ENV['TOKEN']
unless token
  puts 'Provide bot token via env TOKEN or --token option!'
  exit 1
end

logger = Logger.new(options[:logfile] || STDOUT)
bot = Bot.new(token, logger: logger, mpd_host: options[:mpd_host])

bot.run
