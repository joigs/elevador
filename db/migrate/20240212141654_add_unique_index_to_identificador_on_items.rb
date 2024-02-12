class AddUniqueIndexToIdentificadorOnItems < ActiveRecord::Migration[7.1]
  def change
    add_index :items, :identificador, unique: true
  end
end
