class AddLadderRevisionToRevisionPhotos < ActiveRecord::Migration[7.1]
  def change
    add_reference :revision_photos, :ladder_revision, polymorphic: true, null: false
  end
end
