class AddGroupToPlatRevisions < ActiveRecord::Migration[7.1]
  def change
    add_reference :plat_revisions, :group, null: false, foreign_key: true, index: true

  end
end
