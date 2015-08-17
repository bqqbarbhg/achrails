class AddBearerTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bearer_token, :text
  end
end
