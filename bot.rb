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
  class << self
    def def_command(name, &block)
      self.commands = commands.merge(name => block).freeze
    end

    def def_command_processing(name, &block)
      self.command_processors = command_processors.merge(name => block).freeze
    end

    def command_block(command_name)
      commands[command_name]
    end

    def command_processor_block(command_name)
      command_processors[command_name]
    end

    private

    attr_writer :commands
    attr_writer :command_processors

    def commands
      @commands ||= {}.freeze
    end

    def command_processors
      @command_processors ||= {}.freeze
    end
  end

  def initialize(token, options = {})
    @token = token
    @logger = options[:logger]
  end

  def_command '/current' do |message|
    song_info = API.current_song
    text = "#{song_info['artist']} - #{song_info['title']}\n" \
           "Album: #{song_info['album']}"
    respond(message, parse_mode: :markdown, text: text)
  end

  def_command '/playlist' do |message|
    playlists = ['__current__'] + API.playlists
    question = "Which one?\n\n" + playlists.map { |e| "* #{e}" }.join("\n")
    buttons = playlists.map { |e| [e] }
    kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: buttons, one_time_keyboard: true)
    respond(message, text: question, reply_markup: kb)
    start_command(message)
  end

  def_command_processing '/playlist' do |message|
    playlist_name = message.text == '__current__' ? '' : message.text
    songs = API.playlist_songs(playlist_name)
    remove_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    respond(message, text: songs.join("\n"), reply_markup: remove_kb)
    stop_command(message)
  end

  def run
    telegram_bot.listen(&method(:process_message))
  end

  private

  attr_reader :logger, :token

  def process_message(msg)
    return continue_command(msg) if command_in_progress(msg.chat.id)
    return execute_command(msg.text, msg) if command_defined?(msg.text)
  rescue => e
    respond(msg, text: 'Something went wrong, sorry. Check logs, bro')
    stop_command(msg)
    logger.error(e)
  end

  def respond(msg, params = {})
    telegram_bot.api.send_message(params.merge(chat_id: msg.chat.id))
  end

  def execute_command(name, message)
    block = command_block(name)
    raise "#{name} not defined" unless block

    instance_exec(message, &block)
  end

  def continue_command(message)
    command_name = command_in_progress(message.chat.id)
    raise 'no command in progress' unless command_name

    block = command_processor_block(command_name)
    raise "#{command_name} processor not defined" unless block

    instance_exec(message, &block)
  end

  def command_in_progress(chat_id)
    processing_command_hash[chat_id]
  end

  def start_command(message)
    processing_command_hash[message.chat.id] = message.text
  end

  def stop_command(message)
    processing_command_hash.delete(message.chat.id)
  end

  # don't use it directly!
  def processing_command_hash
    @processing_command_hash ||= {}
  end

  def command_block(name)
    self.class.command_block(name)
  end

  alias command_defined? command_block

  def command_processor_block(name)
    self.class.command_processor_block(name)
  end

  def telegram_bot
    @telegram_bot ||= Telegram::Bot::Client.new(token, logger: logger)
  end
end
