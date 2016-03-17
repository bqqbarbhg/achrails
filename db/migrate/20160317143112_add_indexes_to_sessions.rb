class AddIndexesToSessions < ActiveRecord::Migration
  def change
    add_index :sessions, :code, unique: true
    add_index :sessions, :access_token, unique: true
    add_index :sessions, :refresh_token, unique: true
  end
end
