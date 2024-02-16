class AddInstalationNumberToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :instalation_number, :integer
  end
end
