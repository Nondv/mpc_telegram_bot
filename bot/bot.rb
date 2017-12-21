require 'telegram/bot'
require 'json'
require 'rest-client'
require 'yaml'
require 'optparse'
require 'barrymore'

require_relative 'commands'

class Bot
  include Barrymore
  include Commands

  def initialize(token, options = {})
    @token = token
    @logger = options[:logger]
    @mpd_host = options[:mpd_host]
  end

  def run
    telegram_bot.listen(&method(:process_message))
  end

  private

  attr_reader :logger, :token, :mpd_host

  def process_message(msg)
    msg = telegram_to_barrymore(msg)
    return continue_command(msg) if command_in_progress?(msg)
    return execute_command(msg) if command_defined?(msg)
  rescue => e
    respond(msg, text: 'Something went wrong, sorry. Check logs, bro')
    stop_command_processing(msg)
    logger.error(e)
  end

  def telegram_to_barrymore(telegram_message)
    Message.new text: telegram_message.text,
                chat: telegram_message.chat.id
  end

  def formatted_track_info(track_info)
    "#{track_info[:artist]} - #{track_info[:title]}\n" \
    "Album: #{track_info[:album]}"
  end

  def current_volume_text(percents)
    "Current volume is #{percents}%"
  end

  def telegram_bot
    @telegram_bot ||= Telegram::Bot::Client.new(token, logger: logger)
  end

  def respond(msg, params = {})
    telegram_bot.api.send_message(params.merge(chat_id: msg.chat))
  end
end
