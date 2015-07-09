class AddAttachmentToVideo < ActiveRecord::Migration
  def change
      add_attachment :videos, :manifest
  end
end
