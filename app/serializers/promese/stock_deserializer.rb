class Promese::StockDeserializer < PromeseDeserializer

  def persist
    data['message']['content']['product_stock'].each do |stock_item|
      variant = Spree::Variant.find_by(sku: stock_item['product_id'])
      stock_item = variant.stock_items.first
      stock = stock_item['quantity']
      stock = 0 if stock < 0
      stock_item.set_count_on_hand(stock) unless stock == 0 && stock_item.count_on_hand < 0

    end
  end

end
