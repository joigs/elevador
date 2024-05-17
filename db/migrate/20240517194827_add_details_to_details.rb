class AddDetailsToDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :details, :rol_n, :string
    add_column :details, :numero_permiso, :integer
    add_column :details, :fecha_permiso, :date
    add_column :details, :destino, :string
    add_column :details, :recepcion, :string
    add_column :details, :empresa_instaladora, :string
  end
end
