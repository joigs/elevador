class ChangeDefaultV1InConvenios < ActiveRecord::Migration[7.1]
  def change
    change_column_default :convenios, :v1, nil

  end
end
