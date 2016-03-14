class AddCodeToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :code, :string
  end
end
