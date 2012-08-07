require 'bundler/setup'
Bundler.require

require 'bunny'

module Recorders
  class TodaysActivityRecorder

    def initialize(logger)
      @logger = logger
      client = Bunny.new ENV['AMQP']
      client.start
      @queue = client.queue(ENV['QUEUE'] || 'narrative')
      exchange = client.exchange('datainsight', :type => :topic)
    end

    def run
      @queue.subscribe do |msg|
      end
    end
  end
end
