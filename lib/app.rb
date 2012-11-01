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
  {
    :response_info => {:status => "ok"},
    :id => "/todays-activity",
    :web_url => "",
    :details => TodaysActivityModel.new.todays_activity,
    :updated_at => TodaysActivityModel.new.last_collected_at
  }.to_json
end

get '/narrative' do
  content_type :json
  daily_visitors = DailyVisitorsModel.new
  narrative = VisitorsNarrative.new(
    daily_visitors.visitors_for(Date.today - 1),
    daily_visitors.visitors_for(Date.today - 2)
  )
  {
    :response_info => {:status => "ok"},
    :id => "/narrative",
    :web_url => "",
    :details => {
      :source => ["Google Analytics"],
      :data => {
        :content => narrative.message
      }
    },
    :updated_at => daily_visitors.updated_at(Date.today - 1, Date.today - 2)
  }.to_json
end

error do
  logger.error env['sinatra.error']
end
