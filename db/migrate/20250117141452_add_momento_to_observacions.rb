class AddMomentoToObservacions < ActiveRecord::Migration[7.1]
  def change
    add_column :observacions, :momento, :integer
  end
end
