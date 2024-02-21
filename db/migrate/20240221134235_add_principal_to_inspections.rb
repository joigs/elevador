class AddPrincipalToInspections < ActiveRecord::Migration[7.1]
  def change
    add_reference :inspections, :principal, null: true, foreign_key: true
  end
end
