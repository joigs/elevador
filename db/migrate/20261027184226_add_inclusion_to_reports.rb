class AddInclusionToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :inclusion, :boolean, default: false, null: false
  end
end