class AddTypeToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :type, :string
  end
end
