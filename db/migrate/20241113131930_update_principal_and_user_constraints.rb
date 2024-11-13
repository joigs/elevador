class UpdatePrincipalAndUserConstraints < ActiveRecord::Migration[7.1]
  def change
    change_column_null :principals, :business_name, true
    change_column_null :principals, :email, true
    change_column_null :users, :email, true
  end
end
