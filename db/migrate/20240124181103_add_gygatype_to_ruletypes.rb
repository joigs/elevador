class AddGygatypeToRuletypes < ActiveRecord::Migration[7.1]
  def change
    add_column :ruletypes, :gygatype, :string, null: false, default: ""
  end
end
