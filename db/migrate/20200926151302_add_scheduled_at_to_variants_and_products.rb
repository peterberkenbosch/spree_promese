class AddScheduledAtToVariantsAndProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :promese_export_scheduled_at, :datetime, default: nil
    add_column :spree_variants, :promese_export_scheduled_at, :datetime, default: nil
    add_column :spree_orders, :promese_export_scheduled_at, :datetime, default: nil
  end
end
