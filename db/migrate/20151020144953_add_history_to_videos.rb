class AddHistoryToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :compressed_history, :binary
  end
end
