require 'bundler/setup'
Bundler.require

require 'bunny'
require 'json'

require_relative '../unique_visitors_model'

module Recorders
  class TodaysActivityRecorder

    def initialize(logger)
      @logger = logger
      client = Bunny.new ENV['AMQP']
      client.start
      @queue = client.queue(ENV['QUEUE'] || 'todays_activity')
      exchange = client.exchange('datainsight', :type => :topic)

      @queue.bind(exchange, :key => 'google_analytics.visitors.hourly')
      @logger.info("Bound to google_analytics.visitors.hourly, listening for events")
    end

    def run
      @queue.subscribe do |msg|
        @logger.debug("Received a message: #{msg}")
        self.process_message(JSON.parse(msg[:payload], :symbolize_names => true))
      end
    end

    def self.process_message(msg)
      unique_visitors = UniqueVisitors.first(
        :start_at => DateTime.parse(msg[:payload][:start_at]),
        :end_at => DateTime.parse(msg[:payload][:end_at]),
        :site => msg[:payload][:site],
      )
      if unique_visitors
        unique_visitors.value = msg[:payload][:value]
        unique_visitors.save
      else
        UniqueVisitors.create(
          :collected_at => DateTime.parse(msg[:envelope][:collected_at]),
          :start_at => DateTime.parse(msg[:payload][:start_at]),
          :end_at => DateTime.parse(msg[:payload][:end_at]),
          :value => msg[:payload][:value],
          :site => msg[:payload][:site],
        )
      end
    end
  end
end
