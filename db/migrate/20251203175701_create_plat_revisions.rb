class CreatePlatRevisions < ActiveRecord::Migration[7.1]
  def change
    create_table :plat_revisions do |t|
      t.references :item, null: false, foreign_key: true
      t.references :inspection, null: false, foreign_key: true

      t.timestamps
    end
  end
end
