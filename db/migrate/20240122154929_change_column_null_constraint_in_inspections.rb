class ChangeColumnNullConstraintInInspections < ActiveRecord::Migration[7.1]
  def change
    change_column_null :inspections, :validation, true
  end
end
