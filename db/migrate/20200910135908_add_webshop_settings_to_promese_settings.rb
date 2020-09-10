class AddWebshopSettingsToPromeseSettings < ActiveRecord::Migration
  def change
    add_column :promese_settings, :webshop_name, :string
    add_column :promese_settings, :webshop_id, :string
  end
end
