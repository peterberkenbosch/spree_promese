class Promese::StockDeserializer < PromeseDeserializer

  def persist
    data['message']['content']['product_stock'].each do |stock_item|
      begin
        persist_stock_item stock_item
        logger.info "Persisted stock item #{stock_item}"
      rescue StandardError => e
        logger.error e.message
        logger.debug e.backtrace.join("\n")
      end
    end
  end

  def persist_stock_item(stock_data)
    variant = Spree::Variant.find_by(sku: stock_data['product_id'])
    stock_item = variant.stock_items.first
    stock = stock_data['quantity']
    stock -= unprocessed_stock(stock_data)
    stock = 0 if stock < 0

    # Update stock unless we have negative stock and a 0 stock is coming in. Cannot insert negative stock.
    stock_item.set_count_on_hand(stock) unless stock == 0 && stock_item.count_on_hand <= 0
  end

  def unprocessed_stock(stock_item)
    # sum the quantity of line items that are exported but not yet processed by promese. We can deduct this from the incoming stock data to get the most accurate current stock data
    Spree::LineItem
        .joins(:variant, :order => :shipments)
        .where(spree_shipments: {promese_exported: true, promese_processed_at: nil, state: :ready}, spree_variants: {sku: stock_item['product_id']})
        .sum(:quantity)
  end

end
