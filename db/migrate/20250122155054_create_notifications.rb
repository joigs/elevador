class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :title, null: false
      t.text :text, null: false
      t.integer :notification_type, null: false


      t.timestamps
    end
  end
end
