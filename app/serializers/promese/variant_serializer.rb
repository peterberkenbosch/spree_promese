class Promese::VariantSerializer < PromeseSerializer

  def serialize
    begin
      {
          articles: [
              {
                  # companyCode: PromeseSetting.instance.company_code,
                  # suffix: nil,
                  # prefix: nil,
                  description1: record.name.strip.limit(35),
                  description2: record.option_values.pluck(:name).join(', '),
                  articleCode1: record.sku,
                  barcode: record.sku, # EAN CODE
                  articleCode2: record.product_id,
                  styleCode: record.product.promese_property('style_code') || record.product_id,
                  # colorTree: nil,
                  # colorTreeDescription: nil,
                  # colorSort: nil,
                  colorCode: record.option_values.joins(:option_type).where(spree_option_types: {name: PromeseSetting.instance.color_option_type}).first&.id,
                  colorDescription: record.option_values.joins(:option_type).where(spree_option_types: {name: PromeseSetting.instance.color_option_type}).first&.name,
                  # season: record.product.promese_property('season'),
                  sizeCode: record.option_values.joins(:option_type).where(spree_option_types: {name: PromeseSetting.instance.size_option_type}).first&.id,
                  sizeDescription: record.option_values.joins(:option_type).where(spree_option_types: {name: PromeseSetting.instance.size_option_type}).first&.name,
                  sizeSort: record.position,
                  sizeTree: record.product.promese_property('size_tree') || record.product.size_tree,
                  sizeTreeDescription: record.product.promese_property('size_tree_description') || record.product.size_tree_description,
                  articleType: record.product.promese_property('article_type') || 10,
                  articleSubtype: record.product.promese_property('article_sub_type'),
                  material: record.product.promese_property('material'),
                  insuranceValue: record.cost_price || record.price,
                  packagingType: record.product.promese_property('package_type') || 'ST',
                  releaseDate: record.product.available_on&.strftime('%Y-%m-%d'),
                  hsCode: record.product.promese_property('hs_code'),
                  storageType: record.product.promese_property('storage_type') || PromeseSetting.instance.storage_type,
                  # dimension: nil,
                  countryOfOrigin: record.product.promese_property('country_of_origin') || PromeseSetting.instance.country_of_origin,
                  fragile: %w(1 true yes fragile ja).include?(record.product.promese_property('fragile')) || PromeseSetting.instance.products_fragile?,
                  # labelDescription: nil,
                  # subLabelDescription: nil,
                  # boxset: nil,
                  # VATCode: nil,
                  supplierCodeExternal: record.product.promese_property('supplier_code') || PromeseSetting.instance.supplier_code,
                  supplierName: record.product.promese_property('supplier_name') || PromeseSetting.instance.supplier_name,
                  articleNumber: record.id,
              }
          ]
      }
    rescue StandardError => e
      logger.error e.message
      logger.debug e.backtrace.join("\n")
    end
  end

end
