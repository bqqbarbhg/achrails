class MakeExpiresAtToTimestamp < ActiveRecord::Migration
  def change
    remove_column :sessions, :expires_at
    add_column :sessions, :expires_at, :timestamp
  end
end
