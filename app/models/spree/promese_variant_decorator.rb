module PromeseVariantDecorator

  def self.prepended(base)
    base.after_commit :export_to_promese, on: [:update, :create]
  end

  def export_to_promese
    client = Promese::Client.new
    client.export_article(self)
  end

end
Spree::Variant.prepend(PromeseVariantDecorator)
