class AddGroupToRulesPlats < ActiveRecord::Migration[7.1]
  def change
    add_reference :rules_plats, :group, null: true, foreign_key: true, index: true
  end
end
