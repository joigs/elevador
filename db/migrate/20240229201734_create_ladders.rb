class CreateLadders < ActiveRecord::Migration[7.1]
  def change
    create_table :ladders do |t|
      t.string :number
      t.string :point
      t.string :code
      t.string :priority
      t.string :level

      t.timestamps
    end
  end
end
