class DropFlaws < ActiveRecord::Migration[7.1]
  def change
    drop_table :points
  end
end
