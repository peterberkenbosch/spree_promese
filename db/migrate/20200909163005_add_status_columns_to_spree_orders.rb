class AddStatusColumnsToSpreeOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :promese_exported, :boolean
    add_column :spree_orders, :promese_processed_at, :datetime
  end
end
