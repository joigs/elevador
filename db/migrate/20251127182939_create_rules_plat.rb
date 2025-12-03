class CreateRulesPlat < ActiveRecord::Migration[7.1]
  def change
    create_table :rules_plats do |t|
      t.string :code
      t.string :point
      t.string :ref
      t.string :level

      t.timestamps
    end
  end
end
