class ChangeFailToArrayInRevisions < ActiveRecord::Migration[7.1]
  def change
    change_column :revisions, :fail, :string, array: true, default: [], using: 'fail::character varying[]'
  end
end
