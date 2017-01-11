require_relative '../config_wrapper'

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