require 'sinatra'
require 'json'
require 'yaml'
require_relative 'config_wrapper'
require_relative 'mpc_wrapper'

configure do
  set :port, Config.api_port
end

get '/current.json' do
  MpcWrapper.current_track_info.to_json
end

get '/playlists.json' do
  MpcWrapper.playlists.to_json
end

get '/playlist.json' do
  MpcWrapper.playlist_songs(params['name']).to_json
end
