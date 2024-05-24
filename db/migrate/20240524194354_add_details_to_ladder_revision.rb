class AddDetailsToLadderRevision < ActiveRecord::Migration[7.1]
  def change
    add_column :ladder_revisions, :descripcion, :string
    add_column :ladder_revisions, :rol_n, :string
    add_column :ladder_revisions, :numero_permiso, :integer
    add_column :ladder_revisions, :fecha_permiso, :date
    add_column :ladder_revisions, :destino, :string
    add_column :ladder_revisions, :recepcion, :string
    add_column :ladder_revisions, :empresa_instaladora, :string
    add_column :ladder_revisions, :empresa_instaladora_rut, :string
    add_column :ladder_revisions, :porcentaje, :integer
  end
end
