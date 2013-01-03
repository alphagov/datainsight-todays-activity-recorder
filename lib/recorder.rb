require 'json'

require "bundler/setup"
Bundler.require(:default, :recorder)
require "datainsight_recorder/recorder"

require_relative 'model/hourly_unique_visitors'
require_relative 'model/daily_unique_visitors'

class Recorder
  include DataInsight::Recorder::AMQP

  def queue_name
    "datainsight_todays_activity_recorder"
  end

  def routing_keys
    [
      'google_analytics.visitors.hourly',
      'google_analytics.visitors.daily'
    ]
  end

  def update_message(message)
    routing_key = message[:envelope][:_routing_key]
    case routing_key
    when "google_analytics.visitors.hourly"
      HourlyUniqueVisitors.update_from_message(message)
    when "google_analytics.visitors.daily"
      DailyUniqueVisitors.update_from_message(message)
    else
      raise "Unsupported routing key: #{routing_key}"
    end
  end

  private
  def validate_message_value(message)
    raise "No value provided in message payload: #{message.inspect}" unless message[:payload].has_key? :value
    raise "No visitors provided in message value: #{message.inspect}" unless message[:payload][:value].has_key? :visitors
    raise "Invalid value provided in message payload: #{message.inspect}" unless message[:payload][:value][:visitors].is_a? Integer
  end
end
