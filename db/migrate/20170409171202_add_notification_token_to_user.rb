class AddNotificationTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :notification_token, :string
  end
end
