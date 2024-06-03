class MoveColumnsFromLadderRevisionsToLadderDetails < ActiveRecord::Migration[7.1]
  def change
    remove_column :ladder_revisions, :descripcion
    remove_column :ladder_revisions, :rol_n
    remove_column :ladder_revisions, :numero_permiso
    remove_column :ladder_revisions, :fecha_permiso
    remove_column :ladder_revisions, :destino
    remove_column :ladder_revisions, :recepcion
    remove_column :ladder_revisions, :empresa_instaladora
    remove_column :ladder_revisions, :empresa_instaladora_rut
    remove_column :ladder_revisions, :porcentaje
    remove_column :ladder_revisions, :detalle

    add_column :ladder_details, :descripcion, :string
    add_column :ladder_details, :rol_n, :string
    add_column :ladder_details, :numero_permiso, :integer
    add_column :ladder_details, :fecha_permiso, :date
    add_column :ladder_details, :destino, :string
    add_column :ladder_details, :recepcion, :string
    add_column :ladder_details, :empresa_instaladora, :string
    add_column :ladder_details, :empresa_instaladora_rut, :string
    add_column :ladder_details, :porcentaje, :integer
    add_column :ladder_details, :detalle, :string
  end
end
