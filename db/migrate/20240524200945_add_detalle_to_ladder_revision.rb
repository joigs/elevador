class AddDetalleToLadderRevision < ActiveRecord::Migration[7.1]
  def change
    add_column :ladder_revisions, :detalle, :string
  end
end
