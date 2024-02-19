class DropCarpetas < ActiveRecord::Migration[7.1]
  def up
    drop_table :carpetas
  end

  def down
    create_table :carpetas do |t|
      t.integer :number, null: false
      t.string :cumple
      t.boolean :falla
      t.string :comentario
      t.references :revision, null: false, foreign_key: true

      t.timestamps
    end
  end
end
