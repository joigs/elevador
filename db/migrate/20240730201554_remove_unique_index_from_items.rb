class RemoveUniqueIndexFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_index :items, :identificador
    add_index :items, :identificador
  end
end
