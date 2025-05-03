class AddRegionAndComunaToInspections < ActiveRecord::Migration[7.1]
  def change
    add_column :inspections, :region, :string, null: false
    add_column :inspections, :comuna, :string, null: false
  end
end
