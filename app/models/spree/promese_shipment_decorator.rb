module PromeseShipmentDecorator

  def refresh_rates(shipping_method_filter = Spree::ShippingMethod::DISPLAY_ON_FRONT_END)
    return shipping_rates if selected_shipping_rate.present?
    super
  end

end

Spree::Shipment.prepend(PromeseShipmentDecorator)
