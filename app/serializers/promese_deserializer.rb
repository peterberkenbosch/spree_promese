class PromeseDeserializer
  include Promese::Logger

  attr_reader :data

  def initialize(raw_data)
    @data = JSON.parse(raw_data)
  end

  def persist
    raise('persist should be defined in a PromeseDeserializer subclass')
  end

end
