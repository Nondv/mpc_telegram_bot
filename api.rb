require 'sinatra'
require 'json'
require 'yaml'
require_relative 'config_wrapper'
require_relative 'mpc_wrapper'

include MpcWrapper

configure do
  set :port, Config.api_port
end

get '/current.json' do
  current_track_info.to_json
end
