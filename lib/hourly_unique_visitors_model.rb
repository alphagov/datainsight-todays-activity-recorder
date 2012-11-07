require "dm-core"
require "dm-timestamps"
require "dm-validations"
require "dm-aggregates"
require_relative "date_extension"

class HourlyUniqueVisitors
  include DataMapper::Resource
  property :id, Serial

  property :created_at, DateTime # When this measurement was first seen
  property :collected_at, DateTime, :required => true # When this measurement was collected
  property :updated_at, DateTime # When this measurement was last saved to the database

  property :start_at, DateTime, :required => true
  property :end_at, DateTime, :required => true
  property :value, Integer, :required => true

  validates_with_method :validate_value_positive, :if => lambda { |m| not m.value.nil? }
  validates_with_method :validate_hour_period, :if => lambda { |m| not m.end_at.nil? and not m.start_at.nil? }
  validates_with_method :validate_start_at_full_hour, :if => lambda { |m| not m.start_at.nil? }
  validates_with_method :validate_end_at_full_hour, :if => lambda { |m| not m.end_at.nil? }

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

  def validate_hour_period
    if (end_at - start_at) == Rational(1, 24)
      true
    else
      [false, "The time between start at and end at should be an hour."]
    end
  end

  def validate_start_at_full_hour
    validate_full_hour(start_at, "start at")
  end

  def validate_end_at_full_hour
    validate_full_hour(end_at, "end at")
  end

  def validate_full_hour(time, name)
    if time.minute == 0 and time.second == 0 and time.second_fraction == 0
      true
    else
      [false, "The #{name} time has to be at a full hour."]
    end
  end
end