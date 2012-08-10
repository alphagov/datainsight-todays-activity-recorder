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

get '/todays-activity' do
  content_type :json
  today     = Hash[TodaysActivity.visitors_today.map {|each| [each.start_at.hour, each.value] }]
  yesterday = Hash[TodaysActivity.visitors_yesterday.map {|each| [each.start_at.hour, each.value]}]
  average   = Hash[TodaysActivity.last_month_average.map {|each| [each[:hour], each[:value]]}]
  todays_activity = (0..23).map { |hour|
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

  todays_activity.to_json
end
