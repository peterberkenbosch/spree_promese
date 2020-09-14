class Promese::ProductSerializer < PromeseSerializer

  def serialize
    begin
      {
          articles: record.variants.map do |variant|
            Promese::VariantSerializer.new(variant).to_h[:articles].first
          end.compact
      }
    rescue StandardError => e
      logger.error e.message
      logger.debug e.backtrace.join("\n")
    end
  end

end
