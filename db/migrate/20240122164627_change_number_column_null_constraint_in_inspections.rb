class ChangeNumberColumnNullConstraintInInspections < ActiveRecord::Migration[7.1]
  def change
    change_column :inspections, :number, :integer, null: false
  end
end
