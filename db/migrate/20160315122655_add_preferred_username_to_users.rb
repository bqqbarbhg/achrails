class AddPreferredUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :preferred_username, :string
  end
end
