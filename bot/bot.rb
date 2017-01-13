require 'telegram/bot'
require 'json'
require 'rest-client'
require 'yaml'
require 'optparse'

require_relative 'api_client'
require_relative 'dsl'

class Bot
  include DSL

  def initialize(token, options = {})
    @token = token
    @logger = options[:logger]
  end

  def_command '/current' do |message|
    text = formatted_track_info(API.current_song)
    respond(message, parse_mode: :markdown, text: text)
  end

  def_command '/next' do |message|
    text = formatted_track_info(API.next_track)
    respond(message, parse_mode: :markdown, text: text)
  end

  def_command '/previous' do |message|
    text = formatted_track_info(API.previous_track)
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

  def formatted_track_info(track_info)
    "#{track_info['artist']} - #{track_info['title']}\n" \
    "Album: #{track_info['album']}"
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
