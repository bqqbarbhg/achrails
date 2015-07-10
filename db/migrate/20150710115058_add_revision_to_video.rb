class AddRevisionToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :revision, :integer, null: false, default: 1
  end
end
