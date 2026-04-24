class AddFavoritoAdminIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :favorito_admin_id, :bigint
  end
end
