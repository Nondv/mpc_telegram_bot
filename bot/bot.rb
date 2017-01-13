require 'telegram/bot'
require 'json'
require 'rest-client'
require 'yaml'
require 'optparse'

require_relative 'api_client'
require_relative 'commands'

class Bot
  include Commands

  def initialize(token, options = {})
    @token = token
    @logger = options[:logger]
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

  def telegram_bot
    @telegram_bot ||= Telegram::Bot::Client.new(token, logger: logger)
  end
end
