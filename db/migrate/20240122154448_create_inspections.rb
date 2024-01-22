class CreateInspections < ActiveRecord::Migration[7.1]
  def change
    create_table :inspections do |t|
      t.integer :number, null: false
      t.string :place, null: false
      t.date :ins_date, null: false
      t.date :inf_date
      t.integer :validation, null: false
      t.boolean :result

      t.timestamps
    end
    add_index :inspections, :number, unique: true
  end
end
