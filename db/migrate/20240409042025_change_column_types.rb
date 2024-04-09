class ChangeColumnTypes < ActiveRecord::Migration[7.1]
  def change
    change_column :rules, :point, :text
    change_column :ladders, :point, :text
    change_column :ladder_revisions, :points, :text
    change_column :ladder_revisions, :comment, :text
    change_column :revision_nulls, :point, :text
    change_column :revisions, :comment, :text
    change_column :revisions, :points, :text
  end
end
