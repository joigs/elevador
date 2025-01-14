class AddGestionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :gestion, :boolean, default: false, null: false
  end
end
