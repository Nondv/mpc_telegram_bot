require_relative 'dsl'

class Bot
  module Commands
    def self.included(klass)
      klass.class_eval do
        include DSL

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

        def_command '/play' do |message|
          text = formatted_track_info(API.play)
          respond(message, parse_mode: :markdown, text: text)
        end

        def_command '/pause' do |message|
          text = formatted_track_info(API.pause)
          respond(message, parse_mode: :markdown, text: text)
        end

        def_command '/volumeup' do |message|
          text = current_volume_text(API.volume_up)
          respond(message, text: text)
        end

        def_command '/volumedown' do |message|
          text = current_volume_text(API.volume_down)
          respond(message, text: text)
        end

        def_command '/volume' do |message|
          text = current_volume_text(API.volume)
          respond(message, text: text)
        end

        def_command '/update' do |message|
          text = API.update ? 'Update in progress' : 'Something went wrong'
          respond(message, text: text)
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
      end
    end
  end
end
