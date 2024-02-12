class AddNumberToRevisions < ActiveRecord::Migration[7.1]
  def change
    add_column :revisions, :number, :integer, null: false
    add_index :revisions, :number, unique: true
  end
end
