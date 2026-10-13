class CreateSucursals < ActiveRecord::Migration[7.1]
  def up
    create_table :sucursals do |t|
      t.references :principal, null: false, foreign_key: true
      t.string :nombre, null: false
      t.string :place
      t.string :contact_name
      t.string :contact_email
      t.string :cellphone
      t.timestamps
    end

    add_index :sucursals, [:principal_id, :nombre], unique: true

    add_reference :inspections, :sucursal, foreign_key: true, null: true

    execute <<~SQL
      INSERT INTO sucursals (principal_id, nombre, place, contact_name, contact_email, cellphone, created_at, updated_at)
      SELECT id, 'Sucursal 1', place, contact_name, contact_email, cellphone, NOW(), NOW()
      FROM principals
    SQL

    execute <<~SQL
      UPDATE inspections
      INNER JOIN sucursals ON sucursals.principal_id = inspections.principal_id
      SET inspections.sucursal_id = sucursals.id
    SQL
  end

  def down
    remove_reference :inspections, :sucursal, foreign_key: true
    drop_table :sucursals
  end
end