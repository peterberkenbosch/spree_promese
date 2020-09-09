module Promese
  module Logger

    def logger
      ActiveSupport::Logger.new(File.join(Rails.root, 'log', 'promese.log'))
    end

  end
end
