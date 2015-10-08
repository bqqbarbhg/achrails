class AddVideoUrlToVideosAndVideoManifests < ActiveRecord::Migration
  def change
    add_column :videos, :video_url, :string
    add_column :video_manifests, :video_url, :string
  end
end
