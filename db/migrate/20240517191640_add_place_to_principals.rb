class AddPlaceToPrincipals < ActiveRecord::Migration[7.1]
  def change
    add_column :principals, :place, :string
  end
end
