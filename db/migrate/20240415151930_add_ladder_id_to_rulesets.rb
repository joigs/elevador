class AddLadderIdToRulesets < ActiveRecord::Migration[7.1]
  def change
    add_column :rulesets, :ladder_id, :bigint
  end
end
