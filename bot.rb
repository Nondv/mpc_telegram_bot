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

class Bot
  def initialize(token, options = {})
    @token = token
    @logger = options[:logger]
  end

  def run
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
          playlists = ['__current__'] + API.playlists
          question = "Which one?\n\n" + playlists.map { |e| "* #{e}" }.join("\n")
          buttons = playlists.map { |e| [e] }
          kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: buttons, one_time_keyboard: true)
          respond[message, text: question, reply_markup: kb]
          start_command[message]
        else
          case command_in_progress[message]
          when '/playlist'
            playlist_name = message.text == '__current__' ? '' : message.text
            songs = API.playlist_songs(playlist_name)
            remove_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
            respond[message, text: songs.join("\n"), reply_markup: remove_kb]
            stop_command[message]
          end
        end
      end
    end
  end

  private

  attr_reader :logger, :token
end
