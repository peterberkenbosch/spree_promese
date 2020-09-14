module PromeseVariantDecorator

  def self.prepended(base)
    base.after_commit :export_to_promese, on: [:update, :create]
  end

  def export_to_promese
    client = Promese::Client.new
    json = Promese::VariantSerializer.new(article).to_json
    client.export_article(json)
  end

end
Spree::Variant.prepend(PromeseVariantDecorator)
