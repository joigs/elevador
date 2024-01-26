class AddCodeTypeLevelToRules < ActiveRecord::Migration[7.1]
  def change
    add_column :rules, :code, :string
    add_column :rules, :type, :string
    add_column :rules, :level, :string
  end
end
