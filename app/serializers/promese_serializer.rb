class PromeseSerializer
  include Promese::Logger

  attr_reader :record

  def initialize(record)
    @record = record
  end

  def to_h
    serialize
  end

  def to_json
    serialize.to_json
  end

  def serialize
    begin
      raise('serialize method needs to be defined in a promese serializer subclass')
    rescue StandardError => e
      logger.error 'Something went wrong in a serializer. No further information available since the subclass didnt catch the error'
      logger.error e.message
    end
  end

end
