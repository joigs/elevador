class AddFacturacionRefToInspections < ActiveRecord::Migration[7.1]
  def change

  add_reference :inspections, :facturacion, foreign_key: true, null: true

  Inspection.reset_column_information
  Facturacion.reset_column_information

  placeholder = Facturacion.find_by!(number: 0) do |f|
  end

  Inspection.where(facturacion_id: nil).update_all(facturacion_id: placeholder.id)

  change_column_null :inspections, :facturacion_id, false
end
end
