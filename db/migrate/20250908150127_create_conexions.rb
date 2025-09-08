class CreateConexions < ActiveRecord::Migration[7.1]
  def change
    create_table :conexions do |t|
      t.references :original_inspection, null: false, foreign_key: { to_table: :inspections }, index: true
      t.references :copy_inspection,     null: false, foreign_key: { to_table: :inspections }, index: true

      t.timestamps
    end
  end
end
