class PromeseDeserializer
  include Promese::Logger

  attr_reader :data

  def initialize(raw_data)
    @data = JSON.parse(raw_data)

    unless Rails.env.production?
      folder_name = self.class.to_s.demodulize.underscore
      path = Rails.root.join("promese_archive/#{folder_name}")
      Dir.mkdir(path) unless File.exists?(path)
      File.write(File.join(path, "#{Time.now.strftime('%Y%m%d_%H%M%S_%3N')}.json"), raw_data)
    end
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
