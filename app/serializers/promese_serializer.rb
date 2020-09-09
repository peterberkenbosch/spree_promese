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
    raise('serialize method needs to be defined in a promese serializer subclass')
  end

end
