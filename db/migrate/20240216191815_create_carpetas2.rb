class CreateCarpetas2 < ActiveRecord::Migration[7.1]
  def change
    create_table :carpetas2s do |t|
      t.integer :number, null: false
      t.string :cumple, null: false
      t.boolean :falla
      t.string :comentario
      t.references :revision, null: false, foreign_key: true

      t.timestamps
    end
  end
end
