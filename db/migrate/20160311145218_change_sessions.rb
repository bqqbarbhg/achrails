class ChangeSessions < ActiveRecord::Migration
  def change
    remove_column :sessions, :token
    add_column :sessions, :access_token, :string
    add_column :sessions, :refresh_token, :string
    add_column :sessions, :client_id, :string
    add_column :sessions, :expires_at, :time
  end
end
