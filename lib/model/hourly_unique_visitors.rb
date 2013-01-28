require "datainsight_recorder/base_fields"
require "datainsight_recorder/time_series"

class HourlyUniqueVisitors
  include DataMapper::Resource
  include DataInsight::Recorder::BaseFields
  include DataInsight::Recorder::TimeSeries

  property :value, Integer, :required => true

  validates_with_method :validate_value_positive, :if => lambda { |m| not m.value.nil? }
  validates_with_method :validate_time_series_hour

  def self.update_from_message(message)
    query = {
      :start_at => DateTime.parse(message[:payload][:start_at]),
      :end_at => DateTime.parse(message[:payload][:end_at])
    }
    visitors = HourlyUniqueVisitors.first(query)
    visitors = HourlyUniqueVisitors.new(query) unless visitors

    visitors.collected_at = DateTime.parse(message[:envelope][:collected_at])
    visitors.source = message[:envelope][:collector]
    visitors.value = message[:payload][:value][:visitors]
    visitors.save
  end

  def self.last_collected_at
    max(:collected_at) || DateTime.parse("1970-01-01T00:00:00+00:00")
  end

  def self.visitors_yesterday_by_hour(last_collected_at)
    result = all(
      :start_at.gte => last_collected_at.to_midnight - 1,
      :start_at.lt => last_collected_at.to_midnight
    )
    visitors = [nil] * 24
    result.each {|measurement| visitors[measurement.start_at.hour] = measurement.value }
    visitors
  end

  def self.last_week_average_by_hour(last_collected_at)
    result = all(
      :start_at.gte => (last_collected_at - last_collected_at.wday).to_midnight - 7,
      :end_at.lte => (last_collected_at - last_collected_at.wday).to_midnight
    ).group_by { |each| each.start_at.hour }.map { |hour, visitors| [hour, average(visitors)] }
    visitors = [nil] * 24
    result.each {|hour, avg| visitors[hour] = avg}

    visitors
  end

  def self.period(from, to)
    all(:start_at.gte => from, :end_at.lte => to)
  end

  # TODO: replace with calc from stats gem or extract into utility
  def self.average(unique_visitors)
    if unique_visitors.empty?
      0.0
    else
      values = unique_visitors.map(&:value)
      values.reduce(&:+).to_f / values.length
    end
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