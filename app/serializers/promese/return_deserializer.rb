class Promese::ReturnDeserializer < PromeseDeserializer

  attr_reader :order

  # {
  #   "customerNo": "65",
  #   "shipmentId": "438527",
  #   "returnItems": [
  #     {
  #       "lineNumber": 1.0,
  #       "productCodeCustomer": "O45.A001.022",
  #       "eanCode": "5414939674129",
  #       "quantity": 1.0,
  #       "returnStatus": "BAD",
  #       "blameCode": "CAR",
  #       "returnReasonCode": "D"
  #     },
  #     {
  #       "lineNumber": 1.0,
  #       "productCodeCustomer": "O45.A001.022",
  #       "eanCode": "5414939674129",
  #       "quantity": 1.0,
  #       "returnStatus": "GOOD",
  #       "returnReasonCode": "A"
  #     }
  #   ]
  # }

  def persist
    begin
      shipment_number = data['shipmentId']
      @shipment = Spree::Shipment.find_by(number: shipment_number)
      order = @shipment&.order || Spree::Order.friendly.find(shipment_number)

      returned_line_items = data['returnItems'].each_with_object({}) do |return_item_data, hash|
        next if return_item_data['returnStatus'] != 'GOOD'
        hash[order.line_items.joins(:variant).find_by(spree_variants: {sku: return_item_data['eanCode']})] = return_item_data['quantity']
      end.compact
      default_stock_location = Spree::StockLocation.order_default.first

      ra = order.return_authorizations.create(stock_location: default_stock_location, reason: Spree::ReturnAuthorizationReason.first)
      returned_line_items.each do |line_item, returned_quantity|
        if Spree::ReturnItem.new.respond_to?(:return_quantity)
          ra.return_items.create(resellable: false, inventory_unit: order.inventory_units.find_by(line_item_id: line_item.id, state: :shipped), return_quantity: returned_quantity)
        else
          returned_quantity.times do
            ra.return_items.create(resellable: false, inventory_unit: order.inventory_units.find_by(line_item_id: line_item.id, state: :shipped))
          end
        end
      end
      cr = Spree::CustomerReturn.new(stock_location: default_stock_location)
      cr.return_items = ra.return_items
      cr.save!

      ri = Spree::Reimbursement.build_from_customer_return(cr)
      ri.save!
      ri.perform!

      logger.info "Imported returns for order #{order.number}. Returned items: #{returned_line_items.keys.map {|l| l.sku}.to_sentence}"
    rescue StandardError => e
      logger.error "Something went wrong while importing a return for order #{data['shipmentId']}"
      logger.error e.message
      logger.debug e.backtrace.join("\n")
    end
  end
end

