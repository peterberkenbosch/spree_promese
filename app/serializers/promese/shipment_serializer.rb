class Promese::ShipmentSerializer < PromeseSerializer

  def serialize
    begin
      {
          webshop: {
              language_code: record.order.locale == 'nl' ? 'NLD' : 'ENG'
          },
          content: [
              {
                  order_id: "#{record.order.number}-#{record.number}",
                  customer_invoice: serialize_address(record.order.bill_address),
                  customer_shipping: serialize_address(record.order.ship_address).merge({
                                                                                      customer_id: record.order.user.try(:promese_customer_id),
                                                                                      order_date: record.order.completed_at.strftime('%Y-%m-%dT%H:%M:%S'),
                                                                                  }),
                  payment: {
                      price_total: record.item_cost + record.discounted_cost,
                      price_shipping_incl: record.item_cost + record.discounted_cost,
                      price_shipping_excl: record.item_cost,
                      price_discount: record.cost - record.discounted_cost,
                      currency: record.order.currency
                  },
                  order_rows: record.line_items.each_with_index.map(&method(:serialize_line_item)),
                  order_date: record.order.completed_at.strftime('%Y-%m-%dT%H:%M:%S'), #yyyy-MM-dd'T'hh:mm:ss
              }
          ]
      }
    rescue StandardError => e
      logger.error e.message
      logger.debug e.backtrace.join("\n")
    end
  end

  def serialize_address(address)
    {
        customer_firstname: address.firstname,
        customer_lastname: address.lastname,
        customer_address_street: address.address1,
        customer_address_street2: address.address2,
        customer_address_zipcode: address.zipcode,
        customer_address_city: address.city,
        customer_address_country: address.country.iso,
        customer_email: record.order.email,
        customer_telephone: address.phone
    }
  end

  def serialize_line_item(line_item, index)
    {
        row_nr: index + 1,
        sku: line_item.sku,
        name: line_item.product.name,
        qty: line_item.quantity,
        base_price: line_item.price,
        final_price: line_item.total,
        tax_percent: ((line_item.adjustments.find_by(source_type: 'Spree::TaxRate')&.source&.amount || 0.21) * 100).round
    }
  end

end
