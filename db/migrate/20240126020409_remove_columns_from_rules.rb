class RemoveColumnsFromRules < ActiveRecord::Migration[7.1]
  def change
    remove_column :rules, :level, :string, array: true, default: []
    remove_column :rules, :type, :string, array: true, default: []
  end
end
