class CreateRules < ActiveRecord::Migration[7.1]
  def change
    create_table :rules do |t|
      t.string :point , null: false

      t.timestamps
    end
  end
end
