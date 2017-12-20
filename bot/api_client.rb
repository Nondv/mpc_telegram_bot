require_relative '../config/config_wrapper'

module API
  URL = 'localhost:6789'.freeze

  module_function

  def current_song
    execute('current_song')
  end

  def playlists
    execute('playlists')[:names]
  end

  def playlist_songs(name)
    execute('playlist', name: name)[:songs]
  end

  def next_track
    execute('next')
  end

  def previous_track
    execute('previous')
  end

  def play
    execute('play')
  end

  def pause
    execute('pause')
  end

  def volume
    execute('status')[:volume]
  end

  def volume_up
    execute('increase_volume', value: 25)[:volume]
  end

  def volume_down
    execute('decrease_volume', value: 25)[:volume]
  end

  def update
    execute('update')
  end

  def reload
    raise 'TODO'
  end

  def repeat
    execute('repeat')
  end

  def random
    execute('random')
  end

  def execute(action, params = {})
    data = params.merge(action: action)
    response = RestClient.post(URL, data.to_json, content_type: :json)
    JSON.parse(response, symbolize_names: true)
  end
end
