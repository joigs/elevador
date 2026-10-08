class RemovePrincipalIdFromUsers < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :users, :principals
    remove_index :users, :principal_id
    remove_column :users, :principal_id
  end

  def down
    add_column :users, :principal_id, :bigint
    add_index :users, :principal_id
    add_foreign_key :users, :principals
  end
end