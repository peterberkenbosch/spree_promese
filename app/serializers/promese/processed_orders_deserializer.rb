class Promese::ProcessedOrdersDeserializer < PromeseDeserializer

  # {
  #   "message": {
  #     "envelope": {
  #       "webshop": {
  #         "webshop_id": "57",
  #         "webshop_name": "LA Sisters"
  #       },
  #       "sender": {
  #         "sender_name": "Promese Logistics",
  #         "sender_email": "ict@promese.eu"
  #       }
  #     },
  #     "content": {
  #       "processed_orders": [
  #         {
  #           "order_id": "0057000444514",
  #           "order_date": "2020-08-13T11:33:00",
  #           "process_date": "2020-08-14T06:05:16"
  #         },
  #         {
  #           "order_id": "0057000444515",
  #           "order_date": "2020-08-13T11:37:00",
  #           "process_date": "2020-08-14T06:05:19"
  #         },
  #         {
  #           "order_id": "0057000444516",
  #           "order_date": "2020-08-13T11:46:00",
  #           "process_date": "2020-08-14T06:05:21"
  #         },
  #         {
  #           "order_id": "0057000444517",
  #           "order_date": "2020-08-13T11:51:00",
  #           "process_date": "2020-08-14T06:05:24"
  #         },
  #         {
  #           "order_id": "0057000444518",
  #           "order_date": "2020-08-13T11:56:00",
  #           "process_date": "2020-08-14T06:05:27"
  #         },
  #         {
  #           "order_id": "0057000444519",
  #           "order_date": "2020-08-13T11:56:00",
  #           "process_date": "2020-08-14T06:05:27"
  #         },
  #         {
  #           "order_id": "0057000444520",
  #           "order_date": "2020-08-13T11:59:00",
  #           "process_date": "2020-08-14T06:05:29"
  #         },
  #         {
  #           "order_id": "0057000444521",
  #           "order_date": "2020-08-14T12:00:00",
  #           "process_date": "2020-08-14T06:05:32"
  #         },
  #         {
  #           "order_id": "0057000444522",
  #           "order_date": "2020-08-14T12:04:00",
  #           "process_date": "2020-08-14T06:05:35"
  #         },
  #         {
  #           "order_id": "0057000444523",
  #           "order_date": "2020-08-14T12:09:00",
  #           "process_date": "2020-08-14T06:05:37"
  #         },
  #         {
  #           "order_id": "0057000444524",
  #           "order_date": "2020-08-14T12:23:00",
  #           "process_date": "2020-08-14T06:05:40"
  #         },
  #         {
  #           "order_id": "0057000444525",
  #           "order_date": "2020-08-14T12:50:00",
  #           "process_date": "2020-08-14T06:05:42"
  #         },
  #         {
  #           "order_id": "0057000444526",
  #           "order_date": "2020-08-14T01:02:00",
  #           "process_date": "2020-08-14T06:05:45"
  #         },
  #         {
  #           "order_id": "0057000444527",
  #           "order_date": "2020-08-14T01:06:00",
  #           "process_date": "2020-08-14T06:05:47"
  #         },
  #         {
  #           "order_id": "0057000444528",
  #           "order_date": "2020-08-14T01:15:00",
  #           "process_date": "2020-08-14T06:05:50"
  #         },
  #         {
  #           "order_id": "0057000444529",
  #           "order_date": "2020-08-14T01:47:00",
  #           "process_date": "2020-08-14T06:05:52"
  #         },
  #         {
  #           "order_id": "0057000444530",
  #           "order_date": "2020-08-14T02:50:00",
  #           "process_date": "2020-08-14T06:05:55"
  #         },
  #         {
  #           "order_id": "0057000444531",
  #           "order_date": "2020-08-14T03:47:00",
  #           "process_date": "2020-08-14T06:05:57"
  #         },
  #         {
  #           "order_id": "0057000444532",
  #           "order_date": "2020-08-14T03:53:00",
  #           "process_date": "2020-08-14T06:06:00"
  #         },
  #         {
  #           "order_id": "0057000444533",
  #           "order_date": "2020-08-14T03:59:00",
  #           "process_date": "2020-08-14T06:06:02"
  #         },
  #         {
  #           "order_id": "0057000444534",
  #           "order_date": "2020-08-14T04:53:00",
  #           "process_date": "2020-08-14T06:06:05"
  #         },
  #         {
  #           "order_id": "0057000444535",
  #           "order_date": "2020-08-14T06:03:00",
  #           "process_date": "2020-08-14T06:10:13"
  #         },
  #         {
  #           "order_id": "0057000444536",
  #           "order_date": "2020-08-14T06:31:01",
  #           "process_date": "2020-08-14T06:40:16"
  #         },
  #         {
  #           "order_id": "0057000444537",
  #           "order_date": "2020-08-14T06:49:01",
  #           "process_date": "2020-08-14T06:55:14"
  #         },
  #         {
  #           "order_id": "0057000444538",
  #           "order_date": "2020-08-14T06:51:01",
  #           "process_date": "2020-08-14T07:00:16"
  #         }
  #       ]
  #     }
  #   }
  # }

  def persist
    data['message']['content']['processed_orders'].each do |processed_order|
      begin
        shipment_number = processed_order['order_id']
        @shipment = Spree::Shipment.friendly.find_by(number: shipment_number)
        @order = @shipment&.order || Spree::Order.friendly.find(shipment_number)
        if @shipment.blank?
          @order.update(promese_processed_at: processed_order['process_date'])
          @order.shipments.update_all(promese_processed_at: processed_order['process_date'])
        else
          @shipment.update(promese_processed_at: processed_order['process_date'])
        end

        logger.info "Persisted processed order #{@shipment.number}"
      rescue StandardError => e
        logger.error e.message
        logger.debug e.backtrace.join("\n")
      end
    end
  end

end
