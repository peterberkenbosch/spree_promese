class CreatePromeseSettings < ActiveRecord::Migration
  def change
    create_table :promese_settings do |t|
      t.string :company_code
      t.string :color_option_type
      t.string :size_option_type
      t.string :supplier_code
      t.string :supplier_name
      t.string :country_of_origin
      t.string :storage_type
      t.boolean :products_fragile

      t.timestamps null: false
    end
  end
end
