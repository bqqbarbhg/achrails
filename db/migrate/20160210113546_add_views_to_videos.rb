class AddViewsToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :views, :integer, null: false, default: 0
    add_column :users, :recent_views, :json
  end
end
