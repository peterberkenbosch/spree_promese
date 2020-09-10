module Promese
  class Client
    include Promese::Logger
    include HTTParty
    base_uri PromeseSetting.instance.promese_endpoint

    def export_article(article)
      json = Promese::VariantSerializer.new(article).to_json
      resp = self.class.post('/logisiticItem', body: json)
      if resp.success?
        logger.info "Exported article with sku #{article.sku}"
      else
        logger.error "Failed to export order with number #{article.sku}."
        logger.error "Response body: #{response.body}"
        logger.error "Response status: #{response.status}"
      end
    end

    def export_order(order)
      json = Promese::OrderSerializer.new(order).to_json
      resp = self.class.post('/outb2c', body: json)
      if resp.success?
        logger.info "Exported order with number #{order.number}"
      else
        logger.error "Failed to export order with number #{order.number}."
        logger.error "Response body: #{response.body}"
        logger.error "Response status: #{response.status}"
      end
    end

  end
end
