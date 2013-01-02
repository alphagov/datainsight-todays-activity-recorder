require "datainsight_recorder/base_fields"
require "datainsight_recorder/time_series"

require_relative "../date_extension"

class DailyUniqueVisitors
  include DataMapper::Resource
  include DataInsight::Recorder::BaseFields
  include DataInsight::Recorder::TimeSeries

  property :value, Integer, :required => true

  validates_with_method :validate_value_positive, :if => lambda { |m| not m.value.nil? }
  validates_with_method :validate_time_series_day

  def self.update_from_message(message)
    query = {
      :start_at => DateTime.parse(message[:payload][:start_at]),
      :end_at => DateTime.parse(message[:payload][:end_at])
    }
    visitors = DailyUniqueVisitors.first(query)
    visitors = DailyUniqueVisitors.new(query) unless visitors

    visitors.collected_at = DateTime.parse(message[:envelope][:collected_at])
    visitors.source = message[:envelope][:collector]
    visitors.value = message[:payload][:value][:visitors]
    visitors.save
  end

  def self.visitors_for(date)
    result = first(:start_at => date.to_datetime.to_midnight)

    return result.value unless result.nil?
  end

  def self.latest_collected_at(*dates)
    max(:collected_at, :start_at => dates.map {|date| date.to_datetime.to_midnight })
  end

  private
  def validate_value_positive
    if value >= 0
      true
    else
      [false, "Value cannot be negative."]
    end
  end
end