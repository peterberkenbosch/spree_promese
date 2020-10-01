class AddExportOrdersFromToPromeseSettings < ActiveRecord::Migration
  def change
    add_column :promese_settings, :export_orders_from, :datetime
  end
end
