class ChangeValorInIvasToDecimal < ActiveRecord::Migration[7.1]
  def change
    change_column :ivas, :valor, :decimal, precision: 10, scale: 2
  end
end
