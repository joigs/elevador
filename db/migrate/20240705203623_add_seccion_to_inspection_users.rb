class AddSeccionToInspectionUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :inspection_users, :seccion, :integer, default: -1, null: false
  end
end
