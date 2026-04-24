class AllowNilFavoritoAdminIdUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :favorito_admin_id, true
  end
end
