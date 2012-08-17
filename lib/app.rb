require "bundler/setup"

require 'sinatra'
require 'json'

require_relative "unique_visitors_model"
require_relative "todays_activity"
require_relative "datamapper_config"

configure do
  unless test?
    DataMapperConfig.configure
  end
end

def most_recent_collection_date(visitors)
  visitors.map(&:collected_at).max
end

get '/todays-activity' do
  content_type :json
  TodaysActivity.new.todays_activity.to_json
end
