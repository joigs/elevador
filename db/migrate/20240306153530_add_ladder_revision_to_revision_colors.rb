class AddLadderRevisionToRevisionColors < ActiveRecord::Migration[7.1]
  def change
    add_reference :revision_colors, :ladder_revision, polymorphic: true, index: true
  end
end
