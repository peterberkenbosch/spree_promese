class Spree::Api::V1::PromeseWebserviceController < Spree::Api::BaseController

  rescue_from StandardError do |exception|
    render json: {
        error: exception.message
    }, status: 500
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: {
        error: exception.message
    }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: {
        error: exception.message
    }, status: 404
  end

  def retour_b2c
    Promese::ReturnDeserializer.new(request.body).persist
  end

  def ship_b2c
    Promese::ShipmentsDeserializer.new(request.body).persist
  end

  def ship_b2b
    raise 'Not implemented'
  end

  def stock_update
    Promese::StockDeserializer.new(request.body).persist
  end

  def processed_orders
    Promese::ProcessedOrdersDeserializer.new(request.body).persist
  end

end
