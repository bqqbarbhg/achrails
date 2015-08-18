class AddSssGroupToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :sss_group, :string
  end
end
