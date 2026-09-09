class AddActivoToPrincipalsAndUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :principals, :activo, :boolean, default: true, null: false
    add_column :users, :activo, :boolean, default: true, null: false

    add_index :principals, :activo
    add_index :users, :activo
  end
end