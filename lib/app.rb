require "bundler/setup"
Bundler.require(:default, :exposer)

require 'json'

require_relative "hourly_unique_visitors_model"
require_relative "daily_unique_visitors_model"
require_relative "todays_activity_model"
require_relative "daily_visitors_model"
require_relative "visitors_narrative"
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
  TodaysActivityModel.new.todays_activity.to_json
end

get '/narrative' do
  content_type :json
  daily_visitors = DailyVisitorsModel.new
  narrative = VisitorsNarrative.new(
    daily_visitors.visitors_for(Date.today - 1),
    daily_visitors.visitors_for(Date.today - 2)
  )
  {
    :content => narrative.message
  }.to_json
end

error do
  logger.error env['sinatra.error']
end
