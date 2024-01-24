class RenameRuleTypesToNewTableName < ActiveRecord::Migration[7.1]
  def change
    rename_table :ruletypes, :ruletypes
  end
end
