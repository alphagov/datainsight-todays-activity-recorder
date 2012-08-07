require "bundler/setup"

require 'sinatra'
require 'json'

get '/todays-activity.json' do
  content_type :json
  {}.to_json
end
