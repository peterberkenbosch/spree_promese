module PromeseOrderDecorator

  # Accepts an array of hashes {Spree::LineItem: instance => Integer: quantity}
  def refund_line_items(refund_items)
    api_key = Spree::PaymentMethod.where(type: 'Spree::Gateway::MollieGateway').first.get_preference(:api_key)
    payment = payments.where(state: ['completed', 'pending']).last
    mollie_order = ::Mollie::Order.get(payment.source.payment_id, {api_key: api_key})
    mollie_order_refund_lines = refund_items.map do |refund_item, refund_quantity|
      next unless refund_quantity > 0
      line = mollie_order.lines.detect {|line| line.sku == refund_item.mollie_identifier}
      {id: line.id, quantity: refund_quantity} if line
    end.compact
    mollie_order.refund!({lines: mollie_order_refund_lines, api_key: api_key})
  rescue Mollie::Exception => e
    logger.error "Unable to create refund for #{mollie_order_refund_lines}, order: #{number}"
    logger.debug e.message
    logger.debug e.backtrace.join("\n")
  end

end

Spree::Order.prepend(PromeseOrderDecorator)
