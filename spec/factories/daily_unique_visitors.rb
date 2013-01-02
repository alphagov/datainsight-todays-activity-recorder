require_relative "../../lib/datamapper_config"
require_relative "../../lib/model/hourly_unique_visitors_model"

FactoryGirl.define do
  factory :daily_unique_visitors, class: DailyUniqueVisitors do
    collected_at DateTime.now
    source "Example source"
    start_at DateTime.parse("2012-08-06 00:00:00")
    end_at DateTime.parse("2012-08-07 00:00:00")
    value 500
  end
end