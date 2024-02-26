class DropBagsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :bags
  end
end
