class RenameTypeToTypeOfInGroups < ActiveRecord::Migration[7.1]
  def change
    rename_column :groups, :type, :type_of
  end
end
