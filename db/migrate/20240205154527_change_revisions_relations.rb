class ChangeRevisionsRelations < ActiveRecord::Migration[7.1]
  def change
    # Remove existing foreign keys
    remove_foreign_key :revisions, column: :item_id
    remove_foreign_key :revisions, column: :group_id
    remove_foreign_key :revisions, column: :inspection_id

    # Remove existing indexes
    remove_index :revisions, name: "index_revisions_on_item_id"
    remove_index :revisions, name: "index_revisions_on_group_id"
    remove_index :revisions, name: "index_revisions_on_inspection_id"

    # Change columns to hold only one item, group, and inspection
    remove_column :revisions, :item_id
    remove_column :revisions, :group_id
    remove_column :revisions, :inspection_id

    add_reference :revisions, :item, foreign_key: true
    add_reference :revisions, :group, foreign_key: true
    add_reference :revisions, :inspection, foreign_key: true
  end
end
