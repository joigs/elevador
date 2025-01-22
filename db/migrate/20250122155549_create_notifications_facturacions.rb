class CreateNotificationsFacturacions < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications_facturacions do |t|
      t.references :notification, null: false, foreign_key: true
      t.references :facturacion, null: false, foreign_key: true

      t.timestamps
    end

    add_index :notifications_facturacions, [:notification_id, :facturacion_id], unique: true, name: 'index_notifications_facturacions_on_notification_and_facturacion'
  end
end