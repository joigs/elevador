class AddCambioToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :cambio, :date, null: false, default: Date.today
  end
end
