require "dm-core"
require "dm-timestamps"
require "dm-validations"
require "dm-aggregates"

class DailyUniqueVisitors
  include DataMapper::Resource
  property :id, Serial

  property :created_at, DateTime # When this measurement was first seen
  property :collected_at, DateTime, :required => true # When this measurement was collected
  property :updated_at, DateTime # When this measurement was last saved to the database

  property :start_at, DateTime, :required => true
  property :end_at, DateTime, :required => true
  property :value, Integer, :required => true

  validates_with_method :validate_value_positive, :if => lambda { |m| not m.value.nil? }
  validates_with_method :validate_day_period, :if => lambda { |m| not m.end_at.nil? and not m.start_at.nil? }
  validates_with_method :validate_start_at_midnight, :if => lambda { |m| not m.start_at.nil? }
  validates_with_method :validate_end_at_midnight, :if => lambda { |m| not m.end_at.nil? }

  def self.visitors_for(date)
    result = first(:start_at => date.to_datetime.to_midnight)

    return result.value unless result.nil?
  end

  def self.updated_at_for(*dates)
    max(:updated_at, :start_at => dates.map {|date| date.to_datetime.to_midnight })
  end

  private
  def validate_value_positive
    if value >= 0
      true
    else
      [false, "Value cannot be negative."]
    end
  end

  def validate_day_period
    if (end_at - start_at) == 1
      true
    else
      [false, "The time between start at and end at should be a day."]
    end
  end

  def validate_start_at_midnight
    validate_midnight(start_at, "start at")
  end

  def validate_end_at_midnight
    validate_midnight(end_at, "end at")
  end

  def validate_midnight(time, name)
    if time.hour == 0 and time.minute == 0 and time.second == 0 and time.second_fraction == 0
      true
    else
      [false, "The #{name} time has to be at midnight."]
    end
  end
end