class AddRealNameToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :real_name, :string, null: false, default: ''
  end
end
