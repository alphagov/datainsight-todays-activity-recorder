require "bundler/setup"
Bundler.require(:default, :exposer)

require 'json'

require_relative "unique_visitors_model"
require_relative "todays_activity"
require_relative "datamapper_config"

helpers Datainsight::Logging::Helpers

configure do
  enable :logging
  unless test?
    Datainsight::Logging.configure(:type => :exposer)
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

error do
  logger.error env['sinatra.error']
end
