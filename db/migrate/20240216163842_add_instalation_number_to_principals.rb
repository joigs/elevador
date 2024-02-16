class AddInstalationNumberToPrincipals < ActiveRecord::Migration[7.1]
  def change
    add_column :principals, :instalation_number, :integer
  end
end
