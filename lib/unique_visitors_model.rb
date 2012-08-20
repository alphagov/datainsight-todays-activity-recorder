require "dm-core"
require "dm-timestamps"
require "dm-validations"
require "dm-aggregates"

class UniqueVisitors
  include DataMapper::Resource
  property :id, Serial

  property :created_at, DateTime # When this measurement was first seen
  property :collected_at, DateTime # When this measurement was collected
  property :updated_at, DateTime # When this measurement was last saved to the database

  property :site, String
  property :start_at, DateTime
  property :end_at, DateTime
  property :value, Integer

  validates_with_method :validate_hour_period
  validates_with_method :validate_start_at_full_hour
  validates_with_method :validate_end_at_full_hour

  private
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