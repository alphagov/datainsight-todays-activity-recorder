require "dm-core"
require "dm-timestamps"
require "dm-validations"

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
end