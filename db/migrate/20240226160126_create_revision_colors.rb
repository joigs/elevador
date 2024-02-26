class CreateRevisionColors < ActiveRecord::Migration[7.1]
  def change
    create_table :revision_colors do |t|
      t.integer :number
      t.boolean :color
      t.references :revision, null: false, foreign_key: true

      t.timestamps
    end
  end
end
