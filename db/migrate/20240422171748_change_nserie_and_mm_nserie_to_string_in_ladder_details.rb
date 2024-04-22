class ChangeNserieAndMmNserieToStringInLadderDetails < ActiveRecord::Migration[7.1]
  def change
    change_column :ladder_details, :nserie, :string
    change_column :ladder_details, :mm_nserie, :string
  end
end
