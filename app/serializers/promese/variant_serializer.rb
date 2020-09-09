class Promese::VariantSerializer < PromeseSerializer

  def serialize
    {
        article: {
            # action: 'CHG', Default value
            information: {
                companyCode: PromeseSetting.instance.company_code,
                # suffix: nil,
                # prefix: nil,
                description1: record.description,
                description2: record.options_text,
                articleCode1: record.sku,
                barcode: record.sku, # EAN CODE
                articleCode2: record.product_id,
                # colorTree: nil,
                # colorTreeDescription: nil,
                # colorSort: nil,
                colorCode: record.option_values.joins(:option_type).where(spree_option_types: {name: ['color, colour', 'kleur']}).first&.id,
                colorDescription: record.option_values.joins(:option_type).where(spree_option_types: {name: ['color, colour']}).first&.name,
                season: record.product.property('season'),
                sizeCode: record.option_values.joins(:option_type).where(spree_option_types: {name: ['size']}).first&.id,
                sizeDescription: record.option_values.joins(:option_type).where(spree_option_types: {name: ['size']}).first&.name,
                sizeSort: record.position,
                sizeTree: record.product.property('size_tree'),
                sizeTreeDescription: record.product.property('size_tree_description'),
                articleType: record.product.property('article_type'),
                articleSubtype: record.product.property('article_sub_type'),
                material: record.product.property('material'),
                insuranceValue: record.product.cost_price,
                packagingType: record.product.property('package_type') || 'ST',
                releaseDate: record.product.available_on&.strftime('%Y-%m-%d'),
                hsCode: record.product.property('hs_code'),
                storageType: record.product.property('storage_type') || PromeseSetting.instance.storage_type,
                # dimension: nil,
                countryOfOrigin: record.product.property('country_of_origin') || PromeseSetting.instance.country_of_origin,
                fragile: %w(1 true yes fragile ja).include?(record.product.property('fragile')) || PromeseSetting.instance.products_fragile?,
                # labelDescription: nil,
                # subLabelDescription: nil,
                # boxset: nil,
                # VATCode: nil,
                supplierCodeExternal: record.product.property('supplier_code') || PromeseSetting.instance.supplier_code,
                supplierName: record.product.property('supplier_name') || PromeseSetting.instance.supplier_name,
                articleNumber: record.id,
            }
        }
    }
  end

end
