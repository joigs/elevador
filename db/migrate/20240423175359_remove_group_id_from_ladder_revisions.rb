class RemoveGroupIdFromLadderRevisions < ActiveRecord::Migration[7.1]
  def change
    remove_column :ladder_revisions, :group_id, :bigint
  end
end
