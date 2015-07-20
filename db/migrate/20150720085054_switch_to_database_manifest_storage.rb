class SwitchToDatabaseManifestStorage < ActiveRecord::Migration
  def change
    remove_attachment :videos, :manifest
    add_column :videos, :manifest_text, :text, limit: 65535
  end
end
