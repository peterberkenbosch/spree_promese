module PromeseProductDecorator

  def self.prepended(base)
    base.after_save :export_to_promese
  end

  def export_to_promese
    variants.all.each(&:export_to_promese)
  end
end

Spree::Product.prepend(PromeseProductDecorator)
