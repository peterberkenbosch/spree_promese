module Promese
  class Logger < ActiveSupport::Logger

    def error_messages
      @error_messages ||= []
    end

    def error(message)
      save_error_message(message)
      super
    end

    private

    def save_error_message(message)
      @error_messages ||= []
      @error_messages << message
    end

  end
end
