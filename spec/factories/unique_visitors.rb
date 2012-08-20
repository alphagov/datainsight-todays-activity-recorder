require_relative "../../lib/datamapper_config"
require_relative "../../lib/unique_visitors_model"

FactoryGirl.define do
  factory :unique_visitors, class: UniqueVisitors do
    start_at DateTime.parse("2012-08-06 10:00:00")
    end_at DateTime.parse("2012-08-06 11:00:00")
    value 500
    collected_at DateTime.now
    created_at DateTime.now
    updated_at DateTime.now
  end
end