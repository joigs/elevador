class AddColumnsToRules < ActiveRecord::Migration[7.1]
  def change
    add_column :rules, :level, :string
    add_column :rules, :type, :string
  end
end
