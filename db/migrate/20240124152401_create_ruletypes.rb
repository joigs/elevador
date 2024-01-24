class CreateRuletypes < ActiveRecord::Migration[7.1]
  def change
    create_table :ruletypes do |t|
      t.string :rtype

      t.timestamps
    end
  end
end
