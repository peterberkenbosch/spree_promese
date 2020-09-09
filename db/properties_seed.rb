class PropertiesSeed

  def self.execute
    promese_prototype = Spree::Prototype.create(name: 'Promese')

    properties = [
        'season',
        'size_tree',
        'size_tree_description',
        'article_type',
        'article_sub_type',
        'material',
        'package_type',
        'hs_code',
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
  end

end
