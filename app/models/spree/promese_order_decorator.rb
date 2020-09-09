module PromeseOrderDecorator

  def self.prepended(base)
    base.after_save :export_to_promese, if: :should_export_to_promese?
  end

  def promese_processed?
    promese_processed_at.present? && promese_processed_at > Time.now
  end

  def should_export_to_promese?
    completed? && !promese_exported? && shipment_state == 'ready' && (respond_to?(:paid_or_authorized?) ? paid_or_authorized? : paid?)
  end

  def export_to_promese
    order_json = Promese::OrderSerializer.new(self).to_json
    client = Promese::Client.new
    if client.export_order(order_json)
      update(promese_exported: true)
    end
  end

end

Spree::Order.prepend(PromeseOrderDecorator)
