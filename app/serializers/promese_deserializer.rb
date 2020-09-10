class PromeseDeserializer
  include Promese::Logger

  attr_reader :data

  def initialize(raw_data)
    @data = JSON.parse(raw_data)
  end

  def persist
    begin
      raise('persist should be defined in a PromeseDeserializer subclass')
    rescue StandardError => e
      logger.error 'Something went wrong in a deserializer. No further information available since the subclass didnt catch the error'
      logger.error e.message
    end
  end

end
