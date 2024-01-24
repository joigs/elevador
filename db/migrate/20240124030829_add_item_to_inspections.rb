class AddItemToInspections < ActiveRecord::Migration[7.1]
  def change
    add_reference :inspections, :item, null: false, foreign_key: true
  end
end
