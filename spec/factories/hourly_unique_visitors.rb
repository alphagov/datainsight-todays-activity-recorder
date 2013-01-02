require_relative "../../lib/datamapper_config"
require_relative "../../lib/model/hourly_unique_visitors"

FactoryGirl.define do
  factory :hourly_unique_visitors, class: HourlyUniqueVisitors do
    collected_at DateTime.now
    source "Example source"
    start_at DateTime.parse("2012-08-06 10:00:00")
    end_at DateTime.parse("2012-08-06 11:00:00")
    value 500
  end
end