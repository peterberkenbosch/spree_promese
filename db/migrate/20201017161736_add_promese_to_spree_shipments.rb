class AddPromeseToSpreeShipments < ActiveRecord::Migration
  def change
    add_column :spree_shipments, :promese_exported, :boolean, default: false
    add_column :spree_shipments, :promese_processed_at, :datetime
  end
end
