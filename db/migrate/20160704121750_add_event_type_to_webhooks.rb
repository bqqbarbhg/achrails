class AddEventTypeToWebhooks < ActiveRecord::Migration
  def change
    add_column :webhooks, :event_type, :string
  end
end
