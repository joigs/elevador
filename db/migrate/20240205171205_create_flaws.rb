class CreateFlaws < ActiveRecord::Migration[7.1]
  def change
    create_table :flaws do |t|
      t.string :point, null: false
      t.string :code, null: false
      t.string :level, null: false

      t.timestamps
    end
  end
end
