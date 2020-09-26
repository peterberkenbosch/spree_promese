module PromeseExportable
  extend ActiveSupport::Concern

  attr_accessor :skip_promese_export

  included do
    after_save :export_to_promese, unless: :skip_promese_export, if: :should_export_to_promese?
  end

  def export_to_promese_at(datetime)
    if !promese_export_scheduled_at.present? || promese_export_scheduled_at < 1.hour.ago
      Promese::ExportJob.set(wait: (datetime - Time.now).seconds).perform_later(self.id, self.class.to_s)
      update_column(:promese_export_scheduled_at, datetime)
    end
  end

  def export_to_promese
    time = Time.now
    if time.hour <= 6
      export_to_promese_at(Time.parse('7:30'))
    else
      promese_export
    end
  end

end
