require_relative '../config/config_wrapper'

module API
  API_BASE_URL = "localhost:#{Config.api_port}".freeze

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

  def next_track
    api_put('/next.json', {})
  end

  def previous_track
    api_put('/previous.json', {})
  end

  def play
    api_put('/play.json', {})
  end

  def pause
    api_put('/pause.json', {})
  end

  def volume
    api_get('/volume.json')['volume']
  end

  def volume_up
    api_put('/volume/up.json', {})['volume']
  end

  def volume_down
    api_put('/volume/down.json', {})['volume']
  end

  # api_get '/path'
  def api_get(*args)
    api_request(:get, args)
  end

  def api_put(*args)
    api_request(:put, args)
  end

  # api_request :get, ['/path']
  def api_request(req_type, args)
    args[0] = api_url(args[0])
    args.unshift(req_type)
    data = RestClient.send(*args)
    JSON.parse(data)
  end

  def api_url(path)
    path = '/' + path unless path.start_with?('/')
    API_BASE_URL + path
  end
end
