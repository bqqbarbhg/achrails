class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.string :notification_url
      t.references :group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
