class AddLogDatafilesToPromeseSettings < ActiveRecord::Migration
  def change
    add_column :promese_settings, :log_datafiles, :boolean, default: true
  end
end
