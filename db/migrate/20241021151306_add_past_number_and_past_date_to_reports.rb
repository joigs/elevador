class AddPastNumberAndPastDateToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :past_number, :integer, null: true
    add_column :reports, :past_date, :date, null: true
  end
end
