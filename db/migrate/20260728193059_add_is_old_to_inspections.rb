class AddIsOldToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :is_old, :boolean, default: false, null: false
  end
end
