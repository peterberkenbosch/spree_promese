class PromeseSeed

  def self.execute
    Spree::Prototype.where(name: ['Promese', 'Promese global overrides (Configurations -> Promese settings)']).destroy_all

    promese_prototype = Spree::Prototype.create(name: 'Promese')
    promese_global_prototype = Spree::Prototype.create(name: 'Promese global overrides (Configurations -> Promese settings)')

    properties = [
        'season',
        'size_tree',
        'size_tree_description',
        'article_type',
        'article_sub_type',
        'material',
        'package_type',
        'hs_code'
    ]

    optional_properties = [
        'storage_type',
        'country_of_origin',
        'fragile',
        'supplier_code',
        'supplier_name'
    ]

    promese_prototype.properties.create(
        properties.map do |property|
          {name: property, presentation: property.humanize}
        end
    )
    promese_global_prototype.properties.create(
        optional_properties.map do |property|
          {name: property, presentation: property.humanize}
        end
    )
  end

end
