class AddPreviousInspectionIdToConexions < ActiveRecord::Migration[7.1]
  def change
    add_column :conexions, :previous_inspection_id, :bigint
    add_index :conexions, :previous_inspection_id
  end
end
