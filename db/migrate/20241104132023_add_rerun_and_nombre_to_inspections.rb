class AddRerunAndNombreToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :rerun, :boolean, null: false, default: false
    add_column :inspections, :name, :string
  end
end
