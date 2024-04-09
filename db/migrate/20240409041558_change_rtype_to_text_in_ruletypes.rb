class ChangeRtypeToTextInRuletypes < ActiveRecord::Migration[7.1]
  def change
    change_column :ruletypes, :rtype, :text
  end
end
