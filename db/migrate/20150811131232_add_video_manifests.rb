class AddVideoManifests < ActiveRecord::Migration
  def change
    create_table(:video_manifests) do |t|
      t.uuid :uuid, null: false
      t.json :manifest_json, null: false
    end
    add_index :video_manifests, :uuid, unique: true
  end
end
