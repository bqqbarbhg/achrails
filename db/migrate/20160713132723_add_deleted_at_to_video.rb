class AddDeletedAtToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :deleted_at, :datetime
  end
end
