class RemoveInstalationNumberFromReports < ActiveRecord::Migration[7.1]
  def change
    remove_column :reports, :instalation_number, :integer
  end
end
