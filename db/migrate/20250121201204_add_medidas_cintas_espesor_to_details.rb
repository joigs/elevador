class AddMedidasCintasEspesorToDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :details, :medidas_cintas_espesor, :float
  end
end
