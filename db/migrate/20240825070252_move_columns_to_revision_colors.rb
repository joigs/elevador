class MoveColumnsToRevisionColors < ActiveRecord::Migration[7.1]
  def change
    add_column :revision_colors, :codes, :text
    add_column :revision_colors, :points, :text
    add_column :revision_colors, :levels, :text
    add_column :revision_colors, :comment, :text
    add_column :revision_colors, :section, :text
    add_column :revision_colors, :priority, :text

    remove_column :revisions, :fail, :text
    remove_column :ladder_revisions, :fail, :text

    remove_column :revisions, :codes, :text
    remove_column :revisions, :points, :text
    remove_column :revisions, :levels, :text
    remove_column :revisions, :comment, :text
    remove_column :ladder_revisions, :codes, :text
    remove_column :ladder_revisions, :points, :text
    remove_column :ladder_revisions, :levels, :text
    remove_column :ladder_revisions, :comment, :text
    remove_column :ladder_revisions, :number, :text
    remove_column :ladder_revisions, :priority, :text
  end
end
