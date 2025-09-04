class AddCopiaToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :copia, :boolean, null: false, default: false
  end
end
