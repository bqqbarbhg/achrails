class RemoveDbAuth < ActiveRecord::Migration
  def change

      remove_index :users, :reset_password_token

      ## Database authenticatable
      remove_column :users, :encrypted_password, :string, null: false, default: ""

      ## Recoverable
      remove_column :users, :reset_password_token,   :string
      remove_column :users, :reset_password_sent_at, :datetime

      ## Trackable
      remove_column :users, :sign_in_count,      :integer, default: 0, null: false
      remove_column :users, :current_sign_in_at, :datetime
      remove_column :users, :last_sign_in_at,    :datetime
      remove_column :users, :current_sign_in_ip, :inet
      remove_column :users, :last_sign_in_ip,    :inet
  end
end
