module PromeseVariantDecorator

  def self.prepended(base)
    base.after_save :export_to_promese, unless: :skip_promese_export, if: :should_export_to_promese?

    base.include PromeseExportable
  end

  def should_export_to_promese?
    !(is_master? && product.variants.any?)
  end

  def persist_to_promese
    client = Promese::Client.new
    client.export_article(self)
  end

end
Spree::Variant.prepend(PromeseVariantDecorator)
