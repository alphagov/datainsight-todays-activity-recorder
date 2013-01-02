require 'json'

require_relative '../model/hourly_unique_visitors_model'
require_relative '../model/daily_unique_visitors_model'

module Recorders
  class TodaysActivityRecorder

    HOURLY_KEY = 'google_analytics.visitors.hourly'
    DAILY_KEY = 'google_analytics.visitors.daily'

    MESSAGE_PARSING_METHODS = {
      HOURLY_KEY => :process_hourly_message,
      DAILY_KEY => :process_daily_message
    }

    def initialize
      client = Bunny.new ENV['AMQP']
      client.start
      @queue = client.queue(ENV['QUEUE'] || 'todays_activity')
      exchange = client.exchange('datainsight', :type => :topic)

      MESSAGE_PARSING_METHODS.keys.each do |routing_key|
        @queue.bind(exchange, :key => routing_key)
        logger.info("Bound to #{routing_key}, listening for events")
      end
    end

    def run
      @queue.subscribe do |msg|
        begin
          logger.debug { "Received a message: #{msg}" }
          message = JSON.parse(msg[:payload], :symbolize_names => true)
          TodaysActivityRecorder.process_message(msg[:delivery_details][:routing_key], message)
        rescue Exception => e
          logger.error { e }
        end
      end
    end

    def self.process_message(routing_key, message)
      validate_message_value(message)
      send MESSAGE_PARSING_METHODS[routing_key], message
    end

    def self.process_hourly_message(message)
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

    def self.process_daily_message(message)
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
    def self.validate_message_value(message)
      raise "No value provided in message payload: #{message.inspect}" unless message[:payload].has_key? :value
      raise "No visitors provided in message value: #{message.inspect}" unless message[:payload][:value].has_key? :visitors
      raise "Invalid value provided in message payload: #{message.inspect}" unless message[:payload][:value][:visitors].is_a? Integer
    end
  end
end
