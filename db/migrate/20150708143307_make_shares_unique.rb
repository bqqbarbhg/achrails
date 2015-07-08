class MakeSharesUnique < ActiveRecord::Migration
  def up
      remove_index :groups_videos, [:group_id, :video_id]
      remove_index :groups_videos, [:video_id, :group_id]
      add_index :groups_videos, [:group_id, :video_id], unique: true
      add_index :groups_videos, [:video_id, :group_id], unique: true
  end
  def down
      remove_index :groups_videos, [:group_id, :video_id]
      remove_index :groups_videos, [:video_id, :group_id]
      add_index :groups_videos, [:group_id, :video_id]
      add_index :groups_videos, [:video_id, :group_id]
  end
end
