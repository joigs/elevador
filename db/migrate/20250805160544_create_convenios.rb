class CreateConvenios < ActiveRecord::Migration[7.1]
  def change
    create_table :convenios do |t|
      t.date    :fecha_venta, null: false
      t.decimal :n1, precision: 10
      t.decimal :v1, precision: 8, scale: 4, default: "0.1"
      t.references :empresa, null: false, foreign_key: true

      t.timestamps
    end
  end
end
