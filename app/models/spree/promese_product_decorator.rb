module PromeseProductDecorator

  def self.prepended(base)
    base.include PromeseExportable
  end

  def should_export_to_promese?
    self.available?
  end

  def promese_export
    client = Promese::Client.new
    if variants.any?
      variants.each do |v|
        client.export_article(v)
      end
    else
      client.export_article(master)
    end
  end

  def size_tree
    if variants.any? && PromeseSetting.instance.size_option_type
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
