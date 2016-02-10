class CreateEventLog < ActiveRecord::Migration
  def change
    create_table :log_events do |t|
      t.integer :user, null: false
      t.integer :event_type, null: false
      t.integer :event_target, null: false
    end
  end
end
