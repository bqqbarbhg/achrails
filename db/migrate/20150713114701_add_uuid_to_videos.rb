class AddUuidToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :uuid, :uuid
  end
end
