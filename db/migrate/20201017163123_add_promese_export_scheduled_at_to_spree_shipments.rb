class AddPromeseExportScheduledAtToSpreeShipments < ActiveRecord::Migration
  def change
    add_column :spree_shipments, :promese_export_scheduled_at, :datetime
  end
end
