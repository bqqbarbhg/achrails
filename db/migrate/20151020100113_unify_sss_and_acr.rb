class UnifySssAndAcr < ActiveRecord::Migration
  def change
    drop_table :video_manifests
    remove_column :users, :person_id
    remove_column :invitations, :sss_group
    add_column :users, :sss_id, :string
    add_column :groups, :sss_id, :string
  end
end
