require "bundler/setup"
Bundler.require(:default, :exposer)

require 'json'
require "datainsight_recorder/datamapper_config"

require_relative "model/hourly_unique_visitors"
require_relative "model/hourly_unique_visitors_collection"
require_relative "model/daily_unique_visitors"
require_relative "visitors_narrative"
require_relative "initializers"

helpers Datainsight::Logging::Helpers

use Airbrake::Rack
enable :raise_errors

configure do
  enable :logging
  unless test?
    Datainsight::Logging.configure(:type => :exposer)
    DataInsight::Recorder::DataMapperConfig.configure
  end
end

def most_recent_collection_date(visitors)
  visitors.map(&:collected_at).max
end

TIMESTAMP_FORMAT="%Y-%m-%dT%H:%M:%S"

get '/todays-activity' do
  content_type :json
  last_collected_at = HourlyUniqueVisitors.last_collected_at
  requested_date = (last_collected_at - 1).to_date

  visitors_yesterday = HourlyUniqueVisitors.visitors_yesterday_by_hour(last_collected_at)
  collection = HourlyUniqueVisitorsCollection.six_week_period_until(last_collected_at.to_midnight - 1)
  average_traffic_for_day = collection.filter_by_day(requested_date.wday).hourly_average()

  {
    :response_info => {:status => "ok"},
    :id => "/todays-activity",
    :web_url => "",
    :details => {
      :source => ["Google Analytics"],
      :data => 24.times.map do |hour|
        start_at = DateTime.new(requested_date.year, requested_date.month, requested_date.day, hour)
        end_at = start_at + Rational(1, 24)
        {
          :start_at => start_at.strftime(TIMESTAMP_FORMAT),
          :end_at => end_at.strftime(TIMESTAMP_FORMAT),
          :visitors => visitors_yesterday[hour],
          :historical_average => average_traffic_for_day[hour]
        }
      end
    },
    :updated_at => last_collected_at.strftime(TIMESTAMP_FORMAT)
  }.to_json
end

get '/narrative' do
  content_type :json
  narrative = VisitorsNarrative.new(
    DailyUniqueVisitors.visitors_for(Date.today - 1),
    DailyUniqueVisitors.visitors_for(Date.today - 2)
  )
  last_collected_at = DailyUniqueVisitors.latest_collected_at(Date.today - 1, Date.today - 2)
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
    :updated_at => last_collected_at.strftime(TIMESTAMP_FORMAT)
  }.to_json
end

error do
  logger.error env['sinatra.error']
end
