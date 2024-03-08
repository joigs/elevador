class AddLadderRevisionToRevisionNulls < ActiveRecord::Migration[7.1]
  def change
    add_reference :revision_photos, :ladder_revision, polymorphic: true, index: true
  end
end
