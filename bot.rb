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
    api_get('/current.json')
  end

  def playlists
    api_get('/playlists.json')
  end

  def playlist_songs(name)
    api_get('/playlist.json', params: { name: name })
  end

  # api_get '/path'
  def api_get(*args)
    args[0] = api_url(args[0])
    data = RestClient.get(*args)
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
  client_commands = {}
  stop_command = ->(msg) { client_commands.delete(msg.chat.id) }
  start_command = ->(msg) { client_commands[msg.chat.id] = msg.text }
  command_in_progress = ->(msg) { client_commands[msg.chat.id] }
  respond = ->(msg, params = {}) { bot.api.send_message(params.merge(chat_id: msg.chat.id)) }

  bot.listen do |message|
    case message.text
    when '/current'
      song_info = API.current_song
      text = "#{song_info['artist']} - #{song_info['title']}\n" \
             "Album: #{song_info['album']}"
      respond[message, parse_mode: :markdown, text: text]
      stop_command[message]
    when '/playlist'
      question = "Which one?\n\n" + API.playlists.map { |e| "* #{e}" }.join("\n")
      buttons = API.playlists.map { |e| [e] }
      kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: buttons, one_time_keyboard: true)
      respond[message, text: question, reply_markup: kb]
      start_command[message]
    else
      case command_in_progress[message]
      when '/playlist'
        playlist_name = message.text
        songs = API.playlist_songs(playlist_name)
        respond[message, text: songs.join("\n")]
        stop_command[message]
      end
    end
  end
end

File.delete(options[:pidfile]) if options[:pidfile]
