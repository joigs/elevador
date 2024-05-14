class AddEndingToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :ending, :date
  end
end
