class CreateCarpetas < ActiveRecord::Migration[7.1]
  def change
    create_table :carpetas do |t|
      t.integer :number, null: false
      t.string :cumple, null: false
      t.boolean :falla
      t.text :comentario

      t.timestamps
    end
  end
end
