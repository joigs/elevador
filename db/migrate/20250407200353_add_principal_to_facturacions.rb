class AddPrincipalToFacturacions < ActiveRecord::Migration[7.1]
  def change
    add_reference :facturacions, :principal, foreign_key: true, null: true
  end
end
