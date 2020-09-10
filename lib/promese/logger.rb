module Promese
  module Logger

    attr_accessor :error_messages

    def logger
      @logger ||= ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(File.join(Rails.root, 'log', 'promese.log')))
      @logger.formatter = ::Logger::Formatter.new
      @logger
    end




  end
end
