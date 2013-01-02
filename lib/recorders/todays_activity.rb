require 'json'

require "bundler/setup"
Bundler.require(:default, :recorder)
require "datainsight_recorder/recorder"

require_relative '../model/hourly_unique_visitors_model'
require_relative '../model/daily_unique_visitors_model'

module Recorders
  class TodaysActivityRecorder
    include DataInsight::Recorder::AMQP

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
        process_hourly_message(message)
      when "google_analytics.visitors.daily"
        process_daily_message(message)
      else
        raise "Unsupported routing key: #{routing_key}"
      end
    end

    def process_hourly_message(message)
      unique_visitors = HourlyUniqueVisitors.first(
        :start_at => DateTime.parse(message[:payload][:start_at]),
        :end_at => DateTime.parse(message[:payload][:end_at])
      )
      if unique_visitors
        unique_visitors.update(
          collected_at: message[:envelope][:collected_at],
          value: message[:payload][:value][:visitors]
        )
      else
        HourlyUniqueVisitors.create(
          :collected_at => DateTime.parse(message[:envelope][:collected_at]),
          :source => message[:envelope][:collector],
          :start_at => DateTime.parse(message[:payload][:start_at]),
          :end_at => DateTime.parse(message[:payload][:end_at]),
          :value => message[:payload][:value][:visitors]
        )
      end
    end

    def process_daily_message(message)
      unique_visitors = DailyUniqueVisitors.first(
        :start_at => DateTime.parse(message[:payload][:start_at]),
        :end_at => DateTime.parse(message[:payload][:end_at])
      )
      if unique_visitors
        unique_visitors.update(
            collected_at: message[:envelope][:collected_at],
            value: message[:payload][:value][:visitors]
        )
      else
        DailyUniqueVisitors.create(
            :collected_at => DateTime.parse(message[:envelope][:collected_at]),
            :source => message[:envelope][:collector],
            :start_at => DateTime.parse(message[:payload][:start_at]),
            :end_at => DateTime.parse(message[:payload][:end_at]),
            :value => message[:payload][:value][:visitors]
        )
      end
    end

    private
    def validate_message_value(message)
      raise "No value provided in message payload: #{message.inspect}" unless message[:payload].has_key? :value
      raise "No visitors provided in message value: #{message.inspect}" unless message[:payload][:value].has_key? :visitors
      raise "Invalid value provided in message payload: #{message.inspect}" unless message[:payload][:value][:visitors].is_a? Integer
    end
  end
end
