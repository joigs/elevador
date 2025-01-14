class CreateFacturacions < ActiveRecord::Migration[7.1]
  def change
    create_table :facturacions do |t|
      t.integer :number
      t.string :name
      t.date :solicitud
      t.date :emicion
      t.date :entregado
      t.integer :resultado
      t.date :oc
      t.date :factura

      t.timestamps
    end
  end
end
