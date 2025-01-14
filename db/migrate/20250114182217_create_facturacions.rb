class CreateFacturacions < ActiveRecord::Migration[7.1]
  def change
    create_table :facturacions do |t|
      t.integer :number
      t.string :name
      t.date :solicitud, default: -> { 'CURRENT_DATE' }
      t.date :emicion, default: -> { 'CURRENT_DATE' }
      t.date :entregado, default: -> { 'CURRENT_DATE' }
      t.integer :resultado, default: 1
      t.date :oc, default: -> { 'CURRENT_DATE' }
      t.date :factura, default: -> { 'CURRENT_DATE' }

      t.timestamps
    end
  end
end
