class RemoveEventTypeFromWebhook < ActiveRecord::Migration
  def change
    remove_column :webhooks, :event_type, :string
  end
end
