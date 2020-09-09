module PromeseVariantDecorator

  def self.prepended(base)
    base.after_save :export_to_promese, if: :saved_changes?
  end

  def export_to_promese
    variant_json = Promese::VariantSerializer.new(self).to_json
    client = Promese::Client.new
    client.export_article(variant_json)
  end

end
Spree::Variant.prepend(PromeseVariantDecorator)
