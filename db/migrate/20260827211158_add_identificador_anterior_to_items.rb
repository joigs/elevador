class AddIdentificadorAnteriorToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :identificador_anterior, :string
    add_index  :items, :identificador_anterior
  end
end