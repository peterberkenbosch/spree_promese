module PromeseOrderDecorator

  def self.prepended(base)
    base.after_commit :export_to_promese, if: :should_export_to_promese?
  end

  def promese_processed?
    promese_processed_at.present? && promese_processed_at > Time.now
  end

  def should_export_to_promese?
    completed? && !promese_exported? && shipment_state == 'ready' && (respond_to?(:paid_or_authorized?) ? paid_or_authorized? : paid?)
  end

  def export_to_promese
    client = Promese::Client.new
    if client.export_order(self)
      update(promese_exported: true)
    end
  end

  # Accepts an array of hashes {Spree::LineItem: instance => Integer: quantity}
  def refund_line_items(refund_items)
    payment = payments.where(state: ['completed', 'pending']).last
    mollie_order = ::Mollie::Order.get(payment.source.payment_id, {api_key: get_preference(:api_key)})
    mollie_order_refund_lines = refund_items.map do |refund_item, refund_quantity|
      next unless refund_quantity > 0
      line = mollie_order.lines.detect {|line| line.sku == refund_item.mollie_identifier}
      {id: line.id, quantity: refund_quantity} if line
    end.compact
    api_key = Spree::PaymentMethod.where(type: 'Spree::Gateway::MollieGateway').last.get_preference(:api_key)
    mollie_order.refund!({lines: mollie_order_refund_lines, api_key: api_key})
  end

end

Spree::Order.prepend(PromeseOrderDecorator)
