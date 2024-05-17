class AdddDescripcionToDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :details, :descripcion, :string
  end
end
