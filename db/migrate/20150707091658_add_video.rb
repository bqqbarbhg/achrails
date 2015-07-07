class AddVideo < ActiveRecord::Migration
  def change
    create_table(:videos) do |t|
      t.belongs_to :author

      t.timestamps null: false
    end
  end
end
