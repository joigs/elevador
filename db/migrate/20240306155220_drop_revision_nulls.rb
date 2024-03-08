class DropRevisionNulls < ActiveRecord::Migration[7.1]
  def change
    drop_table :revision_nulls
  end
end
