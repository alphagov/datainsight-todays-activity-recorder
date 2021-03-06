require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] = "test"
require "factory_girl"
require "datainsight_recorder/datamapper_config"

require_relative '../lib/model/hourly_unique_visitors'
require_relative '../lib/model/hourly_unique_visitors_collection'
require_relative '../lib/model/day'
require_relative '../lib/model/daily_unique_visitors'

require 'timecop'

Datainsight::Logging.configure(:env => :test)
DataInsight::Recorder::DataMapperConfig.configure(:test)
FactoryGirl.find_definitions

def add_measurements(start_at, end_at)
  while start_at < end_at
    params = {
      collected_at: end_at,
      start_at: start_at,
      end_at: start_at + Rational(1, 24),
      value: 500
    }
    yield(params) if block_given?
    FactoryGirl.create(:hourly_unique_visitors, params)
    start_at += Rational(1, 24)
  end
end


def get_measurement(date, hour)
  HourlyUniqueVisitors.first(start_at: DateTime.new(date.year, date.month, date.day, hour))
end