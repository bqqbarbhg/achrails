class AddRevisionToVideoManifests < ActiveRecord::Migration
  def change
    add_column :video_manifests, :revision, :integer
  end
end
