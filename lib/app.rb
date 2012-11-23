require "bundler/setup"
Bundler.require(:default, :exposer)

require 'json'

require_relative "hourly_unique_visitors_model"
require_relative "daily_unique_visitors_model"
require_relative "visitors_narrative"
require_relative "datamapper_config"
require_relative "initializers"

helpers Datainsight::Logging::Helpers

use Airbrake::Rack
enable :raise_errors

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
  last_collected_at = HourlyUniqueVisitors.last_collected_at

  visitors_yesterday = HourlyUniqueVisitors.visitors_yesterday_by_hour(last_collected_at)
  last_week_average = HourlyUniqueVisitors.last_week_average_by_hour(last_collected_at)

  {
    :response_info => {:status => "ok"},
    :id => "/todays-activity",
    :web_url => "",
    :details => {
      :source => ["Google Analytics"],
      :metric => "visitors",
      :for_date => (last_collected_at - 1).to_date,
      :data => 24.times.map do |hour|
        {
          :hour_of_day => hour,
          :value => {
            :yesterday => visitors_yesterday[hour],
            :last_week_average => last_week_average[hour]
          }
        }
      end
    },
    :updated_at => last_collected_at
  }.to_json
end

get '/narrative' do
  content_type :json
  narrative = VisitorsNarrative.new(
    DailyUniqueVisitors.visitors_for(Date.today - 1),
    DailyUniqueVisitors.visitors_for(Date.today - 2)
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
    :updated_at => DailyUniqueVisitors.updated_at_for(Date.today - 1, Date.today - 2)
  }.to_json
end

error do
  logger.error env['sinatra.error']
end
