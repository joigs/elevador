class CreateJoinTableCarpetasRevisions < ActiveRecord::Migration[7.1]
  def change
    create_join_table :carpetas, :revisions do |t|
      t.index [:carpeta_id, :revision_id]
      t.index [:revision_id, :carpeta_id]
    end
  end
end
