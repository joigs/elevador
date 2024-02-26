class RemoveCodeFromRevisionNulls < ActiveRecord::Migration[7.1]
  def change
    remove_column :revision_nulls, :code
  end
end
