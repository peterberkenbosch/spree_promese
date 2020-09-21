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
    deserializer = Promese::ReturnDeserializer.new(request.raw_post)
    deserializer.persist
    handle_response(deserializer)
  end

  def ship_b2c
    deserializer = Promese::ShipmentsDeserializer.new(request.raw_post)
    deserializer.persist
    handle_response(deserializer)
  end

  def ship_b2b
    raise 'Not implemented'
  end

  def stock_update
    deserializer = Promese::StockDeserializer.new(request.raw_post)
    deserializer.persist
    handle_response(deserializer)
  end

  def processed_orders
    deserializer = Promese::ProcessedOrdersDeserializer.new(request.raw_post)
    deserializer.persist
    handle_response(deserializer)
  end

  private

  def handle_response(response)
    puts response.error_messages.inspect
    if response.error_messages.any?
      render json: {
          error: 'Something went wrong while persisting. Please check your input or contact support',
          errors: response.error_messages
      }, status: 500
    else
      head :ok
    end

  end

end
