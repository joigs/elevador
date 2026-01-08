class CreatePlatRevisionSections < ActiveRecord::Migration[7.1]
  def change
    create_table :plat_revision_sections do |t|
      t.references :plat_revision, null: false, foreign_key: true
      t.integer :section
      t.boolean :color

      t.timestamps
    end
  end
end
