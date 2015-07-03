class AddInvitations < ActiveRecord::Migration
  def change
    create_table(:invitations) do |t|
      t.belongs_to :group
      t.string :expect_email, null: true
      t.string :token, null: false
      t.timestamps null: false
    end
  end
end
