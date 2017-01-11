require 'telegram/bot'
require 'json'
require 'rest-client'
require 'yaml'
require 'optparse'
require_relative 'config_wrapper'

unless Config.bot_token
  puts 'Provide bot token in config.yml first!'
  exit 1
end

module API
  config = YAML.load(File.read('config.yml'))
  API_BASE_URL = "localhost:#{config['api']['port']}".freeze

  module_function

  def current_song
    data = RestClient.get api_url('/current.json')
    JSON.parse(data)
  end

  def api_url(path)
    path = '/' + path unless path.start_with?('/')
    API_BASE_URL + path
  end
end

options = {}
op = OptionParser.new
op.banner = 'Telegram bot for mpc'
op.on('-d', '--daemonize', 'run as daemon') { options[:daemonize] = true }
op.on('-p', '--pid PIDFILE', 'write PID to file') { |value| options[:pidfile] = value }
op.on('-l', '--log LOGFILE', 'write to log instead of stdout') { |value| options[:logfile] = value }
op.parse!

logger = Logger.new(options[:logfile] || STDOUT)
Process.daemon if options[:daemonize] # true - dont change working dir
File.write(options[:pidfile], Process.pid) if options[:pidfile]

Telegram::Bot::Client.run(Config.bot_token, logger: logger) do |bot|
  bot.listen do |message|
    case message.text
    when '/current'
      song_info = API.current_song
      text = "#{song_info['artist']} - #{song_info['title']}\n" \
             "Album: #{song_info['album']}"
      bot.api.send_message(chat_id: message.chat.id, parse_mode: :markdown, text: text)
    end
  end
end

File.delete(options[:pidfile]) if options[:pidfile]
