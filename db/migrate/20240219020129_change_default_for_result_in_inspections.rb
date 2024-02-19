class ChangeDefaultForResultInInspections < ActiveRecord::Migration[7.1]
  def change
    change_column_default :inspections, :result, from: nil, to: "Creado"
  end
end
