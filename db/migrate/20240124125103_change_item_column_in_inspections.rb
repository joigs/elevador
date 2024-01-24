class ChangeItemColumnInInspections < ActiveRecord::Migration[7.1]
  def change
    change_column :inspections, :item_id, :integer, null: true
  end
end
