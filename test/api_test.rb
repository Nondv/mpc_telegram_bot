require 'minitest/autorun'
require 'rack/test'

require_relative '../api'

class ApiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_current
    info = track_info_stub('current')
    MpcWrapper.stub(:current_track_info, info) do
      get '/current.json'
      assert_equal info, JSON.parse(last_response.body)
    end
  end

  def test_playlists
    playlists_stub = %w(pl1 pl2 pl3)
    MpcWrapper.stub(:playlists, playlists_stub) do
      get '/playlists.json'
      assert_equal playlists_stub, JSON.parse(last_response.body)
    end
  end

  def test_playlist
    songs_stub = %w(song1 song2 song3)
    MpcWrapper.stub(:playlist_songs, songs_stub) do
      get '/playlist.json', params: { name: 'some name' }
      assert_equal songs_stub, JSON.parse(last_response.body)
    end
  end

  def test_next_track
    info = track_info_stub('next')
    MpcWrapper.stub(:next_track, info) do
      put '/next.json'
      assert_equal info, JSON.parse(last_response.body)
    end
  end

  def test_previous_track
    info = track_info_stub('prev')
    MpcWrapper.stub(:previous_track, info) do
      put '/previous.json'
      assert_equal info, JSON.parse(last_response.body)
    end
  end

  def test_play
    info = track_info_stub('play')
    MpcWrapper.stub(:play, info) do
      put '/play.json'
      assert_equal info, JSON.parse(last_response.body)
    end
  end

  def test_pause
    info = track_info_stub('pause')
    MpcWrapper.stub(:pause, info) do
      put '/pause.json'
      assert_equal info, JSON.parse(last_response.body)
    end
  end

  private

  def track_info_stub(value)
    { 'artist' => value, 'album' => value, 'title' => value }
  end
end
