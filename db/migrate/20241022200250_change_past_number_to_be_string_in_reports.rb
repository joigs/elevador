class ChangePastNumberToBeStringInReports < ActiveRecord::Migration[7.1]
  def change
    change_column :reports, :past_number, :string
  end
end
