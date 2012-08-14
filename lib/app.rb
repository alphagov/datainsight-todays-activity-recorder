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
  visitors_today = TodaysActivity.visitors_today
  visitors_yesterday = TodaysActivity.visitors_yesterday
  last_month_average = TodaysActivity.last_month_average
  today     = Hash[visitors_today.map {|each| [each.start_at.hour, each.value] }]
  yesterday = Hash[visitors_yesterday.map {|each| [each.start_at.hour, each.value]}]
  average   = Hash[last_month_average.map {|each| [each[:hour], each[:value]]}]
  todays_activity = {}
  todays_activity[:values] = (0..23).map { |hour|
    result = {
      :hour_of_day => hour,
      :visitors => {
        :yesterday => yesterday[hour],
        :monthly_average => average[hour]
      }
    }
    if today[hour]
      result[:visitors][:today] = today[hour]
    end
    result
  }

  todays_activity[:live_at] = 
    most_recent_collection_date(visitors_today + visitors_yesterday)
  todays_activity.to_json
end
