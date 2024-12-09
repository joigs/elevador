class AddEmpresaToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :empresa, :string
  end
end
