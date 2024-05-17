class AddEmpresaInstaladoraRutToDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :details, :empresa_instaladora_rut, :string
  end
end
