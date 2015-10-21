class UseRevisionBlocks < ActiveRecord::Migration
  def change
    remove_column :videos, :compressed_history
    remove_column :videos, :revision
    add_column :videos, :revision_num, :integer, null: false

    create_table(:video_revision_blocks) do |t|
      t.belongs_to :video, index: true, required: true
      t.integer :first_num, null: false
      t.integer :last_num, null: false
      t.binary :compressed_revisions, null: false
    end
  end
end
