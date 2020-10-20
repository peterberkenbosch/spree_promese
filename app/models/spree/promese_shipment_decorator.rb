module PromeseShipmentDecorator

  def self.prepended(base)
    base.include Promese::Logging
    base.include PromeseExportable

    base.state_machine.after_transition to: :ready, do: :export_to_promese
    base.after_commit :export_to_promese
  end
  def promese_processed?
    promese_processed_at.present? && promese_processed_at > Time.now
  end

  def should_export_to_promese?
    order.completed? && !promese_exported? && determine_state(order) == 'ready'
  end

  def export_to_promese
    return unless should_export_to_promese?
    Rails.logger.info "EXPORTING #{self.class.to_s} #{self.number}"
    time = Time.now
    if time.hour <= 6 || (self.is_a?(Spree::Shipment) && PromeseSetting.instance.export_orders_from.present? && Time.now < PromeseSetting.instance.export_orders_from)
      delayed_time = Time.parse('7:30')
      delayed_time = PromeseSetting.instance.export_orders_from if delayed_time < PromeseSetting.instance.export_orders_from
      export_to_promese_at(delayed_time.to_time)
    else
      persist_to_promese
    end
  end

  def persist_to_promese
    client = Promese::Client.new
    if client.export_shipment(self)
      update(promese_exported: true)
    end
  end

  def refresh_rates(shipping_method_filter = Spree::ShippingMethod::DISPLAY_ON_FRONT_END)
    return shipping_rates if selected_shipping_rate.present?
    super
  end

end

Spree::Shipment.prepend(PromeseShipmentDecorator)
