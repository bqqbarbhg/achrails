class AddRegistrationIdsToUser < ActiveRecord::Migration
  def change
    add_column :users, :registration_ids, :string, array: true, default: []
  end
end
