class RemoveNumberFromRevisions < ActiveRecord::Migration[7.1]
  def change
    remove_column :revisions, :number
  end
end
