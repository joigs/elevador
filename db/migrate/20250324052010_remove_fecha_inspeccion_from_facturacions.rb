class RemoveFechaInspeccionFromFacturacions < ActiveRecord::Migration[7.1]
  def change
    remove_column :facturacions, :fecha_inspeccion, :date
  end
end
