class AddNameToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :name, :string
    add_index :groups, :name, unique: true
  end
end
