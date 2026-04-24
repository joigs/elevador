class CreateUserPreferencias < ActiveRecord::Migration[7.1]
  def change
    create_table :user_preferencias do |t|
      t.references :user, null: false, foreign_key: true
      t.references :preferencia, null: false, foreign_key: true
      t.boolean :valor, default: false
      t.timestamps
    end
  end
end
