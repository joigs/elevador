class CreateDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :details do |t|
      t.string :detalle
      t.string :marca
      t.string :modelo
      t.integer :n_serie
      t.string :mm_marca
      t.integer :mm_n_serie
      t.float :potencia
      t.integer :capacidad
      t.integer :personas
      t.string :ct_marca
      t.integer :ct_cantidad
      t.float :ct_diametro
      t.float :medidas_cintas
      t.string :rv_marca
      t.integer :rv_n_serie
      t.integer :paradas
      t.integer :embarques
      t.string :sala_maquinas
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
