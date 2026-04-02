class AddRellenoToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :relleno, :boolean, default: false, null: false
  end
end
