class AddExtraToLogEvents < ActiveRecord::Migration
  def change
    add_timestamps :log_events
    add_column :log_events, :extra, :integer, null: true
    add_column :log_events, :state, :integer, null: true
  end
end
