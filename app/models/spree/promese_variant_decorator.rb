module PromeseVariantDecorator

  def self.prepended(base)
    base.after_save :export_to_promese
  end

  def export_to_promese
    return if is_master? && product.variants.any?
    client = Promese::Client.new
    client.export_article(self)
  end

end
Spree::Variant.prepend(PromeseVariantDecorator)
