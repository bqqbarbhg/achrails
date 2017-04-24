class RemoveNotificationTokenFromUsers < ActiveRecord::Migration
  def change
      remove_column :users, :notification_token
  end
end
