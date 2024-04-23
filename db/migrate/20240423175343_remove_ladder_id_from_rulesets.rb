class RemoveLadderIdFromRulesets < ActiveRecord::Migration[7.1]
  def change
    remove_column :rulesets, :ladder_id, :bigint
  end
end
