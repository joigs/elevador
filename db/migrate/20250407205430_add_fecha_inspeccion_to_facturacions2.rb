class AddFechaInspeccionToFacturacions2 < ActiveRecord::Migration[7.1]
  def change
    add_column :facturacions, :fecha_inspeccion, :date
  end
end
