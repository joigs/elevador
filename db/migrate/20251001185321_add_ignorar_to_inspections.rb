class AddIgnorarToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :ignorar, :boolean, default: false, null: false
  end
end
