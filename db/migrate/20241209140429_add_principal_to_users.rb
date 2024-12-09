class AddPrincipalToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :users, :principal
    add_reference :users, :principal, foreign_key: true
  end
end
