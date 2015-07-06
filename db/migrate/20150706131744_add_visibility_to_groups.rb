class AddVisibilityToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :visibility, :integer, default: 0
  end
end
