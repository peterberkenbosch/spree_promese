class Promese::ExportJob < ActiveJob::Base
  queue_as :default

  def perform(record_id, record_class)
    record = record_class.constantize.find(record_id)
    record.export_to_promese
    record.skip_promese_export = true
    record.update_column(:promese_export_scheduled_at, nil)
  end
end
