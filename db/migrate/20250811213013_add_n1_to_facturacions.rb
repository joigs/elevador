class AddN1ToFacturacions < ActiveRecord::Migration[7.1]
  def change
    add_column :facturacions, :n1, :integer
  end
end
