module PromeseProductDecorator

  def self.prepended(base)
    base.after_save :export_to_promese, if: :saved_changes?
  end

  def export_to_promese
    variants.all.each(&:export_to_promese)
  end
end

Spree::Product.prepend(PromeseProductDecorator)
