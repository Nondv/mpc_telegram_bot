require 'minitest/autorun'
require 'rack/test'

require_relative '../api'

class ApiTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_current
    current_track_stub = { 'artist' => '1', 'album' => '2', 'title' => '3' }
    MpcWrapper.stub(:current_track_info, current_track_stub) do
      get '/current.json'
      assert_equal current_track_stub, JSON.parse(last_response.body)
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
    track_info_stub = { 'artist' => 'next', 'album' => 'next', 'title' => 'next' }

    MpcWrapper.stub(:next_track, track_info_stub) do
      put '/next.json'
      assert_equal track_info_stub, JSON.parse(last_response.body)
    end
  end


  def test_previous_track
    track_info_stub = { 'artist' => 'prev', 'album' => 'prev', 'title' => 'prev' }

    MpcWrapper.stub(:previous_track, track_info_stub) do
      put '/previous.json'
      assert_equal track_info_stub, JSON.parse(last_response.body)
    end
  end
end
