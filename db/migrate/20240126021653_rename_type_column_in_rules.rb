class RenameTypeColumnInRules < ActiveRecord::Migration[7.1]
  def change
    rename_column :rules, :type, :ins_type
  end
end
