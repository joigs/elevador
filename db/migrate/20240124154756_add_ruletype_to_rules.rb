class AddRuletypeToRules < ActiveRecord::Migration[7.1]
  def change
    add_reference :rules, :ruletype, null: false, foreign_key: true
  end
end
