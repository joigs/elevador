class DropRuleTypesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :ruletypes

  end
end
