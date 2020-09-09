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
      rescue StandardError => e
        logger.info e.message
        logger.debug e.backtrace.join("\n")
      end
    end
  end

  private

  def persist_shipment(shipment_data)
    @order = Spree::Order.friendly.find(shipment_data['order_id'])
    case shipment_data['status']
    when 'ShipComplete', 'ShipPartial'
      ship_items(shipment_data)
    else
      cancel_items(shipment_data)
    end
  end

  def ship_items(shipment_data)
    shipment = @order.shipments.detect do |s|
      shipment_data['order_rows'].all? do |order_row|
        s.inventory_units.joins(:variant, :line_item).exists?(spree_variants: {sku: order_row['sku']}, quantity: order_row['qty_delivered'])
      end
    end
    shipment = move_items(shipment_data) unless shipment
    shipment.update(tracking: shipment_data['track_and_trace_nr'].first['value'])
    shipment.ship!
  end

  # Create a new shipment with the items to be shipped and return it.
  # @return Spree::Shipment
  def move_items(shipment_data)
    new_shipment = @order.shipments.create
    shippable_inventory_units = @order.inventory_units.where.not(state: :shipped).select do |inventory_unit|
      shipment_data['order_rows'].any? do |order_row|
        inventory_unit.variant.sku == order_row['sku'] && inventory_unit.quantity >= order_row['qty_delivered']
      end
    end
    shippable_inventory_units.each do |inventory_unit|
      shippable_row = shipment_data['order_rows'].detect { |row| row['sku'] == inventory_unit.variant.sku }
      inventory_unit.shipment.transfer_to_shipment(inventory_unit.variant, shippable_row['qty_delivered'], new_shipment)
    end
    new_shipment
  end

  def cancel_items(shipment_data)
    refund_items = shipment_data['order_rows'].map do |order_row|
      {
          @order.line_items.joins(:variant).find_by(spree_variants: {sku: order_row['sku']}) => order_row['qty_cancelled']
      }
    end
    @order.refund_line_items(refund_items)
  end

end
