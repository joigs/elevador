class RemoveIndexIdentificadorFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_index :items, name: 'index_items_on_identificador'
  end
end
