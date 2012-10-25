require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative '../lib/hourly_unique_visitors_model'
require_relative '../lib/daily_unique_visitors_model'
require_relative '../lib/datamapper_config'

require 'timecop'

Datainsight::Logging.configure(:env => :test)
DataMapperConfig.configure(:test)
FactoryGirl.find_definitions

def add_measurements(start_at, end_at)
  while start_at < end_at
    params = {
      start_at: start_at,
      end_at: start_at + Rational(1, 24),
      value: 500
    }
    yield(params) if block_given?
    FactoryGirl.create(:unique_visitors, params)
    start_at += Rational(1, 24)
  end
end