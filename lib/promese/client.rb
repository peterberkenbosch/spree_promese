module Promese
  class Client
    include HTTParty
    base_uri PromeseSetting.instance.promese_endpoint

    def initialize

    end

    def export_article(json)
      self.class.post('/logisiticItem', body: json)
    end

    def export_order(json)
      self.class.post('/outb2c', body: json)
    end

  end
end
