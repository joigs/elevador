class AddGygatypeNumberToRuletypes < ActiveRecord::Migration[7.1]
  def change
    add_column :ruletypes, :gygatype_number, :string
  end
end
