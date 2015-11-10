class AddPublicityToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :is_public, :boolean, null: false, default: false
  end
end
