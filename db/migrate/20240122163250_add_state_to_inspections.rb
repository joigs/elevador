class AddStateToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :state, :string, default: "Abierto"
  end
end
