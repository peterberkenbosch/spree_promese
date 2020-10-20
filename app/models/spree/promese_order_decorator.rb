module PromeseOrderDecorator



end

Spree::Order.prepend(PromeseOrderDecorator)
