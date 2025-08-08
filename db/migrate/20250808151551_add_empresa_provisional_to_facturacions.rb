class AddEmpresaProvisionalToFacturacions < ActiveRecord::Migration[7.1]
  def change
    add_column :facturacions, :empresa_provisional, :string
  end
end
