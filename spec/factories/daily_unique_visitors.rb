require_relative "../../lib/datamapper_config"
require_relative "../../lib/hourly_unique_visitors_model"

FactoryGirl.define do
  factory :daily_unique_visitors, class: DailyUniqueVisitors do
    start_at DateTime.parse("2012-08-06 00:00:00")
    end_at DateTime.parse("2012-08-07 00:00:00")
    value 500
    collected_at DateTime.now
    created_at DateTime.now
    updated_at DateTime.now
  end
end