require 'json'

require_relative '../unique_visitors_model'

module Recorders
  class TodaysActivityRecorder

    def initialize
      client = Bunny.new ENV['AMQP']
      client.start
      @queue = client.queue(ENV['QUEUE'] || 'todays_activity')
      exchange = client.exchange('datainsight', :type => :topic)

      @queue.bind(exchange, :key => 'google_analytics.visitors.hourly')
      logger.info("Bound to google_analytics.visitors.hourly, listening for events")
    end

    def run
      @queue.subscribe do |msg|
        begin
          logger.debug { "Received a message: #{msg}" }
          TodaysActivityRecorder.process_message(JSON.parse(msg[:payload], :symbolize_names => true))
        rescue Exception => e
          logger.error { e }
        end
      end
    end

    def self.process_message(message)
      validate_message_value(message)
      unique_visitors = UniqueVisitors.first(
          :start_at => DateTime.parse(message[:payload][:start_at]),
          :end_at => DateTime.parse(message[:payload][:end_at])
      )
      if unique_visitors
        unique_visitors.update(
            collected_at: message[:envelope][:collected_at],
            value: message[:payload][:value][:visitors]
        )
      else
        UniqueVisitors.create(
            :collected_at => DateTime.parse(message[:envelope][:collected_at]),
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
