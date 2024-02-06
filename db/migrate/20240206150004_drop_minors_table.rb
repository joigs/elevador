class DropMinorsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :minors
  end
end
