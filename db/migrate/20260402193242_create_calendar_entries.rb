class CreateCalendarEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :calendar_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.date :entry_date, null: false
      t.text :content, null: false
      t.timestamps
    end

    add_index :calendar_entries, [:user_id, :entry_date], unique: true
    add_index :calendar_entries, :entry_date
  end
end
