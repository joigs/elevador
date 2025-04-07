class AddFechaEntregaToFacturacions < ActiveRecord::Migration[7.1]
  def change
    add_column :facturacions, :fecha_entrega, :date
  end
end
