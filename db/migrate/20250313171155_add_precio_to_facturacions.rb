class AddPrecioToFacturacions < ActiveRecord::Migration[7.1]
  def change
    add_column :facturacions, :precio, :float, null: true
  end
end
