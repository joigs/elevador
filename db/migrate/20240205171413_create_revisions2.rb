class CreateRevisions2 < ActiveRecord::Migration[7.1]
  def change
    create_table :revisions do |t|
      t.references :inspection, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.timestamps
    end
  end
end
