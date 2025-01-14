class CreateUserPermisos < ActiveRecord::Migration[7.1]
  def change
    create_table :user_permisos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :permiso, null: false, foreign_key: true

      t.timestamps
    end
  end
end
