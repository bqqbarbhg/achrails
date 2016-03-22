class AddUploadTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :upload_token, :string
  end
end
