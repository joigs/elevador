class ChangeColumnTypeOfResultInInspections < ActiveRecord::Migration[7.1]
  def change
    rename_column :inspections, :validation, :valid_time
  end
end
