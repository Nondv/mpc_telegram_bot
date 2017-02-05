require 'sinatra'
require 'json'
require 'yaml'
require_relative 'config/config_wrapper'
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

put '/next.json' do
  MpcWrapper.next_track.to_json
end

put '/previous.json' do
  MpcWrapper.previous_track.to_json
end

put '/pause.json' do
  MpcWrapper.pause.to_json
end

put '/play.json' do
  MpcWrapper.play.to_json
end

get '/volume.json' do
  { volume: MpcWrapper.volume }.to_json
end

put '/volume/up.json' do
  { volume: MpcWrapper.volume('+25') }.to_json
end

put '/volume/down.json' do
  { volume: MpcWrapper.volume('-25') }.to_json
end

post '/update.json' do
  MpcWrapper.update.to_json
end
