class RemoveValorFromUserPreferencias < ActiveRecord::Migration[7.1]
  def change
    remove_column :user_preferencias, :valor, :boolean
  end
end
