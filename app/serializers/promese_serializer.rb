class PromeseSerializer
  include Promese::Logging

  attr_reader :record

  def initialize(record)
    @record = record

    unless Rails.env.production?
      folder_name = self.class.to_s.demodulize.underscore
      path = Rails.root.join("promese_archive/#{folder_name}")
      Dir.mkdir(path) unless File.exists?(path)
      File.write(File.join(path, "#{Time.now.strftime('%Y%m%d_%H%M%S_%3N')}.json"), JSON.pretty_generate(to_h))
    end
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
