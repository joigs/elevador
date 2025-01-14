class AddSuperToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :super, :boolean, default: false, null: false
  end
end
