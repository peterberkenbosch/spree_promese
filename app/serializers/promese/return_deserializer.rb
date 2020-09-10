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
      @order = Spree::Order.friendly.find(data['shipmentId'])
      returned_line_items = data['returnItems'].map do |return_item_data|
        {
            order.line_items.joins(:variant).find_by(spree_variants: {sku: return_item_data['eanCode']}) => return_item_data['quantity']
        }
      end
      default_stock_location = Spree::StockLocation.order_default.first

      ra = order.return_authorizations.create(stock_location: default_stock_location, reason: Spree::ReturnAuthorizationReason.first)
      returned_line_items.each do |line_item, returned_quantity|
        ra.return_items.create(inventory_unit: order.inventory_units.find_by(line_item: line_item, state: :shipped), return_quantity: returned_quantity)
      end
      cr = Spree::CustomerReturn.new(stock_location: default_stock_location)
      cr.return_items = ra.return_items
      cr.save!

      ri = Spree::Reimbursement.build_from_customer_return(cr)
      ri.save!
      ri.perform!
    rescue StandardError => e
      logger.error "Something went wrong while importing a return for order #{data['shipmentId']}"
      logger.error e.message
      logger.debug e.backtrace.join("\n")
    end
  end
end

