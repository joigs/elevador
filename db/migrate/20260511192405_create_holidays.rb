class CreateHolidays < ActiveRecord::Migration[7.1]
  def change
    create_table :holidays do |t|
      t.date :holiday_date, null: false

      t.timestamps
    end

    add_index :holidays, :holiday_date, unique: true
  end
end