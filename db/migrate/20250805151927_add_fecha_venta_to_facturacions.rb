class AddFechaVentaToFacturacions < ActiveRecord::Migration[7.1]
  def change
    add_column :facturacions, :fecha_venta, :date
  end
end
