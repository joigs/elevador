class ChangeSerialNumbersToStringInDetails < ActiveRecord::Migration[7.1]
  def change
    change_column :details, :n_serie, :string
    change_column :details, :mm_n_serie, :string
    change_column :details, :rv_n_serie, :string
  end
end
