class AddMonthAndYearToConvenios < ActiveRecord::Migration[7.1]
  def change
    add_column :convenios, :month, :integer
    add_column :convenios, :year, :integer
  end
end
