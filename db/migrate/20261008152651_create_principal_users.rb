class CreatePrincipalUsers < ActiveRecord::Migration[7.1]
  def up
    create_table :principal_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :principal, null: false, foreign_key: true
      t.timestamps
    end

    add_index :principal_users,
              [:user_id, :principal_id],
              unique: true,
              name: "index_principal_users_on_user_and_principal"

    execute <<~SQL
      INSERT INTO principal_users (user_id, principal_id, created_at, updated_at)
      SELECT id, principal_id, NOW(), NOW()
      FROM users
      WHERE principal_id IS NOT NULL
    SQL
  end

  def down
    drop_table :principal_users
  end
end