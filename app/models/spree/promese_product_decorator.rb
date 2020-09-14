module PromeseProductDecorator

  def self.prepended(base)
    base.after_commit :export_to_promese, on: [:update, :create]
  end

  def export_to_promese
    if variants.any?
      variants.each &:export_to_promese
    else
      master.export_to_promese
    end
  end

  def size_tree
    if variants.any?
      "#{variants.first.option_value(PromeseSetting.instance.size_option_type)} - #{variants.last.option_value(PromeseSetting.instance.size_option_type)}"
    else
      nil
    end
  end

  alias :size_tree_description :size_tree

  def promese_property(property_name)
    product_properties.joins(:property).find_by(spree_properties: {id: Spree::Property.where(name: property_name).first}).try(:value)
  end

end

Spree::Product.prepend(PromeseProductDecorator)
