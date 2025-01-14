class CreateObservacions < ActiveRecord::Migration[7.1]
  def change
    create_table :observacions do |t|
      t.text :texto
      t.references :facturacion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
