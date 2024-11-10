class AddRevisionIdToAnothers < ActiveRecord::Migration[7.1]
  def change
    add_reference :anothers, :revision, null: false, foreign_key: true
  end
end
