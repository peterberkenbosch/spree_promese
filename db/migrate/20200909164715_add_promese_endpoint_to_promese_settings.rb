class AddPromeseEndpointToPromeseSettings < ActiveRecord::Migration
  def change
    add_column :promese_settings, :promese_endpoint, :string
  end
end
