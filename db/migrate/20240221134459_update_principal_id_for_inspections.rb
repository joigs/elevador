class UpdatePrincipalIdForInspections < ActiveRecord::Migration[7.1]
  def up
    Inspection.includes(:item).find_each do |inspection|
      inspection.update_columns(principal_id: inspection.item.principal_id) if inspection.item
    end

    change_column_null :inspections, :principal_id, false
  end

  def down
    change_column_null :inspections, :principal_id, true
  end
end
