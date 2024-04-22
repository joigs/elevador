class ChangeColumnTypesInRevisions < ActiveRecord::Migration[7.1]
  def change
    change_column :revisions, :codes, :text
    change_column :revisions, :levels, :text
    change_column :revisions, :fail, :text
  end
end
