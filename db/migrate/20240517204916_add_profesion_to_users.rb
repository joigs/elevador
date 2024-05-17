class AddProfesionToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :profesion, :string
  end
end
