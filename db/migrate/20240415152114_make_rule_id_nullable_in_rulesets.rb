class MakeRuleIdNullableInRulesets < ActiveRecord::Migration[7.1]
  def change
    change_column_null :rulesets, :rule_id, true
  end
end
