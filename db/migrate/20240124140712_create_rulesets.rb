class CreateRulesets < ActiveRecord::Migration[7.1]
  def change
    create_table :rulesets do |t|
      t.belongs_to :group, null: false, foreign_key: true
      t.belongs_to :rule, null: false, foreign_key: true

      t.timestamps
    end
  end
end
