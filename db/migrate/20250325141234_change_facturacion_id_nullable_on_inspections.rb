class ChangeFacturacionIdNullableOnInspections < ActiveRecord::Migration[7.1]
  def change
    change_column_null :inspections, :facturacion_id, true
  end
end
