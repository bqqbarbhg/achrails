class SwitchToDatabaseManifestStorage < ActiveRecord::Migration
  def change
    add_column :videos, :manifest_text, :text, limit: 65535
  end
end
