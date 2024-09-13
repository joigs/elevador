class AddTablaToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :tabla, :boolean, default: true
  end
end
