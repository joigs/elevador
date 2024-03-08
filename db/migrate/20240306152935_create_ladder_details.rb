class CreateLadderDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :ladder_details do |t|
      t.string :marca
      t.string :modelo
      t.integer :nserie
      t.string :mm_marca
      t.integer :mm_nserie
      t.float :potencia
      t.integer :capacidad
      t.integer :personas
      t.integer :peldaños
      t.float :longitud
      t.integer :inclinacion
      t.integer :ancho
      t.float :velocidad
      t.integer :fabricacion
      t.string :procedencia
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
