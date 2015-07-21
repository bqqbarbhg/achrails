class ChangeManifestTextToJson < ActiveRecord::Migration
  def change
    remove_column :videos, :manifest_text, :text, limit: 65535
    add_column :videos, :manifest_json, :json
  end
end
