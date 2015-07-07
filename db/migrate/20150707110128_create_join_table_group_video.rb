class CreateJoinTableGroupVideo < ActiveRecord::Migration
  def change
    create_join_table :groups, :videos do |t|
      t.index [:group_id, :video_id]
      t.index [:video_id, :group_id]
    end
  end
end
