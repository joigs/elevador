class AddIdentificadorToInspections < ActiveRecord::Migration[7.1]
  def up
    add_column :inspections, :identificador, :string


    execute <<~SQL
      UPDATE inspections
      INNER JOIN items ON items.id = inspections.item_id
      SET inspections.identificador = items.identificador
      WHERE inspections.item_id IS NOT NULL
    SQL

    add_index :inspections, :identificador
  end

  def down
    remove_column :inspections, :identificador
  end
end