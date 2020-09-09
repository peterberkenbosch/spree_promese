class Promese::ReturnDeserializer < PromeseDeserializer

  def persist
    begin
    #   TODO: Make this
    rescue StandardError => e
      logger.info e.message
      logger.debug e.backtrace.join("\n")
    end
  end

end

