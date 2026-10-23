class CreateSucursalUsers < ActiveRecord::Migration[7.1]
  def up
    create_table :sucursal_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sucursal, null: false, foreign_key: true
      t.timestamps
    end

    add_index :sucursal_users, [:user_id, :sucursal_id], unique: true, name: "index_sucursal_users_on_user_and_sucursal"

    execute <<~SQL
      INSERT INTO sucursal_users (user_id, sucursal_id, created_at, updated_at)
      SELECT principal_users.user_id, sucursals.id, NOW(), NOW()
      FROM principal_users
      INNER JOIN sucursals ON sucursals.principal_id = principal_users.principal_id
    SQL
  end

  def down
    drop_table :sucursal_users
  end
end