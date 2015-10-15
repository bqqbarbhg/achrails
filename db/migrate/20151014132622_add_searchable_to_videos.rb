class AddSearchableToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :searchable, :text
    add_column :video_manifests, :searchable, :text
  end
end
