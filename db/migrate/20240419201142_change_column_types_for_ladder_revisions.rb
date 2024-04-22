class ChangeColumnTypesForLadderRevisions < ActiveRecord::Migration[7.1]
  def change
    change_column :ladder_revisions, :codes, :text
    change_column :ladder_revisions, :levels, :text
    change_column :ladder_revisions, :fail, :text
    change_column :ladder_revisions, :number, :text
    change_column :ladder_revisions, :priority, :text
  end
end
