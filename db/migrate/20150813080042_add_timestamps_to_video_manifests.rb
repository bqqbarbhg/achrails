class AddTimestampsToVideoManifests < ActiveRecord::Migration
  def change
    add_timestamps(:video_manifests, null: false)
  end
end
