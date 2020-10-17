class Promese::ShipmentsDeserializer < PromeseDeserializer

  # {
  #   "message": {
  #     "envelope": {
  #       "webshop": {
  #         "webshop_id": "57",
  #         "webshop_name": "LA Sisters"
  #       },
  #       "sender": {
  #         "sender_name": "Promese Logistics",
  #         "sender_email": "ict@promese.eu"
  #       }
  #     },
  #     "content": {
  #       "order_status": [
  #         {
  #           "order_id": "0057000398945",
  #           "status": "ShipComplete",
  #           "track_and_trace_nr": [
  #             {
  #               "shipment_direction": "ship",
  #               "type": "Francois",
  #               "value": "http://www.francois.com/Tracking?tracknumbers\u003d394753149970\u0026language\u003denglish\u0026action\u003dtrack\u0026cntry_code\u003dEN",
  #               "code": "456"
  #             },
  #             {
  #               "shipment_direction": "ship",
  #               "type": "Fedex",
  #               "value": "http://www.fedex.com/Tracking?tracknumbers\u003d394753149970\u0026language\u003denglish\u0026action\u003dtrack\u0026cntry_code\u003dEN",
  #               "code": "456"
  #             }
  #           ],
  #           "order_rows": [
  #             {
  #               "row_nr": 2,
  #               "sku": "8719797117007",
  #               "qty_ordered": 1,
  #               "qty_delivered": 1,
  #               "qty_cancelled": 0
  #             },
  #             {
  #               "row_nr": 3,
  #               "sku": "8719797031327",
  #               "qty_ordered": 1,
  #               "qty_delivered": 1,
  #               "qty_cancelled": 0
  #             }
  #           ]
  #         },
  #         {
  #           "order_id": "0057000398980",
  #           "status": "ShipComplete",
  #           "track_and_trace_nr": [
  #             {
  #               "shipment_direction": "ship",
  #               "type": "GLS BtC",
  #               "value": "https://www.gls-info.nl/Tracking?parcelNo\u003d56570117163466\u0026zipcode\u003dNW109LB\u0026LANG\u003dEN",
  #               "code": "789"
  #             }
  #           ],
  #           "order_rows": [
  #             {
  #               "row_nr": 2,
  #               "sku": "8719797126184",
  #               "qty_ordered": 1,
  #               "qty_delivered": 1,
  #               "qty_cancelled": 0
  #             },
  #             {
  #               "row_nr": 3,
  #               "sku": "8719797127525",
  #               "qty_ordered": 1,
  #               "qty_delivered": 1,
  #               "qty_cancelled": 0
  #             },
  #             {
  #               "row_nr": 4,
  #               "sku": "5420074353744",
  #               "qty_ordered": 1,
  #               "qty_delivered": 1,
  #               "qty_cancelled": 0
  #             }
  #           ]
  #         }
  #       ]
  #     }
  #   }
  # }

  def persist
    data['message']['content']['order_status'].each do |shipment_data|
      begin
        persist_shipment shipment_data
        logger.info "Persisted shipment for order #{shipment_data['order_id']} with status #{shipment_data['status']}"
      rescue StandardError => e
        logger.error "Something went wrong while persisting a shipment for order #{shipment_data['order_id']} with status #{shipment_data['status']}"
        logger.error e.message
        logger.debug e.backtrace.join("\n")
      end
    end
  end

  private

  def persist_shipment(shipment_data)
    order_number, shipment_number = shipment_data['order_id'].split('-')
    @order = Spree::Order.friendly.find(order_number)
    @shipment = Spree::Shipment.friendly.find(shipment_number) if shipment_number

    case shipment_data['status']
    when 'ShipComplete', 'ShipPartial'
      if shipment_data['order_rows'].any? { |order_row| order_row['qty_cancelled'] > 0 }
        cancel_items(shipment_data)
      end
      ship_items(shipment_data)
    else
      cancel_items(shipment_data)
    end
  end

  def ship_items(shipment_data)
    find_shipment(shipment_data) unless @shipment

    @shipment.update(tracking: shipment_data['track_and_trace_nr'].detect { |track| track['shipment_direction'] == 'ship' }['value'])
    @shipment.ship!
  end

  def find_shipment(shipment_data)
    @shipment = @order.shipments.detect do |s|
      shipment_data['order_rows'].select {|r| r['qty_delivered'] > 0}.all? do |order_row|
        s.manifest.detect do |manifest_item|
          manifest_item.variant.sku == order_row['sku']
          manifest_item.states['on_hand'] == order_row['qty_delivered']
        end
      end
    end
    @shipment = move_items(shipment_data) unless @shipment
  end

  # Create a new shipment with the items to be shipped and return it.
  # @return Spree::Shipment
  def move_items(shipment_data)
    shippable_inventory_units = shipment_data['order_rows'].map do |order_row|
      @order.inventory_units
          .joins(:shipment, :line_item => :variant)
          .where.not(state: [:shipped, :backordered], spree_shipments: {id: nil})
          .where(spree_variants: {sku: order_row['sku']}, spree_line_items: {quantity: order_row['qty_delivered']..Float::INFINITY}).first
    end.compact

    raise 'Cannot match all order rows with available inventory units' unless shipment_data['order_rows'].size == shippable_inventory_units.size

    new_shipment = @order.shipments.create(stock_location: Spree::StockLocation.find_by(default: true))
    new_shipment.shipping_rates.create(shipping_method: @order.shipments.first.shipping_method, cost: 0, selected: true)
    new_shipment.address = @order.ship_address
    new_shipment.save

    shippable_inventory_units.each do |inventory_unit|
      shippable_row = shipment_data['order_rows'].detect { |row| row['sku'] == inventory_unit.variant.sku }
      inventory_unit.shipment.transfer_to_shipment(inventory_unit.variant, shippable_row['qty_delivered'], new_shipment)
    end
    new_shipment.ready!
    new_shipment
  end

  def cancel_items(shipment_data)
    refund_items = shipment_data['order_rows'].each_with_object({}) do |order_row, hash|
      hash[@order.line_items.joins(:variant).find_by(spree_variants: {sku: order_row['sku']})] = order_row['qty_cancelled']
    end
    @order.refund_line_items(refund_items)
    refund_items.each do |line_item, cancelled_quantity|
      line_item.decrement(:quantity, cancelled_quantity)
      line_item.save
    end
  end

end
