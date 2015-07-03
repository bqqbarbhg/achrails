class RemoveQFromAdmin < ActiveRecord::Migration
  def change
    rename_column :memberships, :admin?, :admin
  end
end
