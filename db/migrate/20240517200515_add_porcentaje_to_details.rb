class AddPorcentajeToDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :details, :porcentaje, :integer
  end
end
