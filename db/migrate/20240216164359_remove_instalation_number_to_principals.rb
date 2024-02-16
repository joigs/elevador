class RemoveInstalationNumberToPrincipals < ActiveRecord::Migration[7.1]
  def change
    remove_column :principals, :instalation_number, :string
  end
end
