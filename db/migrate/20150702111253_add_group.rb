class AddGroup < ActiveRecord::Migration
  def change
    create_table(:groups) do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    create_table(:memberships) do |t|
      t.belongs_to :user, index: true
      t.belongs_to :group, index: true

      t.boolean :admin, default: false

      t.timestamps null: false
    end
  end
end
