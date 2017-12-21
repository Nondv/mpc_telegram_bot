require 'ruby-mpd-client'

class Bot
  module Commands
    def connection
      @connection ||= MPD::Connection.new(host: mpd_host, port: 6600)
    end

    def reconnect
      connection.connect
      connection.gets # first response
    end

    def connected?
      MPD::Commands::Ping.new(connection: connection).execute
    end

    def exec_command(klass, *args)
      reconnect unless connected?
      klass.new(connection: connection).execute(*args)
    end

    def song_info(song)
      artist = song['Artist']
      title = song['Title']
      if !artist && !title
        song['file']
      else
        album = song['Album']
        "#{artist} - #{title}" + (album ? "\nAlbum: #{album}" : '')
      end
    end

    def current_song_info
      song_info(exec_command(MPD::Commands::CurrentSong))
    end

    def current_status
      status = exec_command(MPD::Commands::Status)
      "Volume: #{status['volume']}\n" \
      "Random: #{status['random'] == '1'}" \
      "Repeat: #{status['repeat'] == '1'}"
    end

    def self.included(klass)
      klass.class_eval do
        def self.def_command(name, &block)
          define_command(name, &block)
        end

        def_command '/current' do |message|
          respond(message, parse_mode: :markdown, text: current_song_info)
        end

        def_command '/next' do |message|
          exec_command(MPD::Commands::Next)
          respond(message, parse_mode: :markdown, text: current_song_info)
        end

        def_command '/previous' do |message|
          exec_command(MPD::Commands::Previous)
          respond(message, parse_mode: :markdown, text: current_song_info)
        end

        def_command '/play' do |message|
          exec_command(MPD::Commands::Play)
          respond(message, parse_mode: :markdown, text: current_song_info)
        end

        def_command '/pause' do |message|
          exec_command(MPD::Commands::Pause)
          respond(message, parse_mode: :markdown, text: current_song_info)
        end

        def_command '/volumeup' do |message|
          volume = exec_command(MPD::Commands::Status)['volume'].to_i
          next_volume = [100, volume + 25].min
          exec_command(MPD::Commands::SetVolume, next_volume)
          respond(message, text: "Volume: #{next_volume}")
        end

        def_command '/volumedown' do |message|
          volume = exec_command(MPD::Commands::Status)['volume'].to_i
          next_volume = [0, volume - 25].max
          exec_command(MPD::Commands::SetVolume, next_volume)
          respond(message, text: "Volume: #{next_volume}")
        end

        def_command '/volume' do |message|
          respond(message,
                  parse_mode: :markdown,
                  text: exec_command(MPD::Commands::Status)['volume'])
        end

        def_command '/update' do |message|
          exec_command(MPD::Commands::Update)
          respond(message, parse_mode: :markdown, text: 'Update started')
        end

        def_command '/clear' do |message|
          exec_command(MPD::Commands::CurrentPlaylistClear)
          respond(message, parse_mode: :markdown, text: 'Done')
        end

        def_command '/reload' do |message|
          files = exec_command(MPD::Commands::AllFiles)
          exec_command(MPD::Commands::CurrentPlaylistClear)
          exec_command(MPD::Commands::CurrentPlaylistAdd, files)
          respond(message, parse_mode: :markdown, text: 'Done')
        end

        def_command '/repeat' do |message|
          next_state = '1' != exec_command(MPD::Commands::Status)['repeat']
          exec_command(MPD::Commands::Repeat, next_state)
          respond(message, parse_mode: :markdown, text: current_status)
        end

        def_command '/random' do |message|
          next_state = '1' != exec_command(MPD::Commands::Status)['random']
          exec_command(MPD::Commands::Random, next_state)
          respond(message, parse_mode: :markdown, text: current_status)
        end

        def_command '/playlist' do |message|
          playlists = exec_command(MPD::Commands::PlaylistList)
          if playlists.empty?
            respond(message, text: 'Seems like you dont have any playlists')
          else
            question = "What playlist do you wanna load?\n\n" + playlists.map { |e| "* #{e}" }.join("\n")
            buttons = playlists.map { |e| [e] }
            kb = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: buttons, one_time_keyboard: true)
            respond(message, text: question, reply_markup: kb)
            start_command_processing(message)
          end
        end

        define_command_continuation '/playlist' do |message|
          exec_command(MPD::Commands::PlaylistLoad, message.text)
          remove_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
          respond(message, text: 'Done', reply_markup: remove_kb)
          stop_command_processing(message)
        end
      end
    end
  end
end
