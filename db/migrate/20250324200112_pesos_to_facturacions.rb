class PesosToFacturacions < ActiveRecord::Migration[7.1]
  def change
    add_column :facturacions, :pesos, :integer
  end
end
