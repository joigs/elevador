class DropRevisionColors < ActiveRecord::Migration[7.1]
  def change
    drop_table :revision_colors
  end
end
