module Promese
  module Logging
    def logger
      @logger ||= ActiveSupport::TaggedLogging.new(Promese::Logger.new(File.join(Rails.root, 'log', 'promese.log')))
      @logger.formatter = ::Logger::Formatter.new

      @logger
    end

    def error_messages
      logger.error_messages
    end

  end
end
