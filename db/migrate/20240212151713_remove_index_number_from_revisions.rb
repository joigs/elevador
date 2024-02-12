class RemoveIndexNumberFromRevisions < ActiveRecord::Migration[7.1]
  def change
    remove_index :revisions, :number
  end
end
