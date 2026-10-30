class ChangeInclusionDefaultOnReports < ActiveRecord::Migration[7.1]
  def change
    change_column_default :reports, :inclusion, from: false, to: true
  end
end