require "rspec"

ENV['RACK_ENV'] = "test"
require "factory_girl"
require_relative "../lib/unique_visitors_model"
require_relative "../lib/datamapper_config"

DataMapperConfig.configure(:test)
FactoryGirl.find_definitions

def add_measurements(start_at, end_at, &block)
  while start_at < end_at
    FactoryGirl.create(:unique_visitors,
                       start_at: start_at,
                       end_at: start_at + Rational(1, 24),
                       value: block ? block.call(start_at) : 500
    )

    start_at += Rational(1, 24)
  end
end