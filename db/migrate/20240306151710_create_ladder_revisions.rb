class CreateLadderRevisions < ActiveRecord::Migration[7.1]
  def change
    create_table :ladder_revisions do |t|
      t.string :codes, array: true, default: []
      t.string :points, array: true, default: []
      t.string :levels, array: true, default: []
      t.string :fail, array: true, default: []
      t.string :comment, array: true, default: []
      t.string :number, array: true, default: []
      t.string :priority, array: true, default: []
      t.references :inspection, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
