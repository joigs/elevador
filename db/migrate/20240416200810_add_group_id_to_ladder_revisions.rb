class AddGroupIdToLadderRevisions < ActiveRecord::Migration[7.1]
  def change
    add_column :ladder_revisions, :group_id, :bigint, null: true
  end
end
