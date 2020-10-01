module PromeseOrderDecorator

  def self.prepended(base)
    base.include Promese::Logging
    base.include PromeseExportable
  end

  def finalize!
    super

    export_to_promese if should_export_to_promese?
  end

  def promese_processed?
    promese_processed_at.present? && promese_processed_at > Time.now
  end

  def should_export_to_promese?
    completed? && !promese_exported? && (respond_to?(:paid_or_authorized?) ? paid_or_authorized? : paid?)
  end

  def persist_to_promese
    client = Promese::Client.new
    if client.export_order(self)
      update(promese_exported: true)
    end
  end

  def export_to_promese
    Rails.logger.info "EXPORTING #{self.class.to_s} with ID #{self.id}"
    time = Time.now
    if time.hour <= 6 || (self.is_a?(Spree::Order) && PromeseSetting.instance.export_orders_from.present? && Time.now < PromeseSetting.instance.export_orders_from)
      delayed_time = Time.parse('7:30')
      delayed_time = PromeseSetting.instance.export_orders_from if delayed_time < PromeseSetting.instance.export_orders_from
      export_to_promese_at(delayed_time.to_time)
    else
      persist_to_promese
    end
  end

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
