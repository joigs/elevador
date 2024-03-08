class CreateRevisionColorspoli < ActiveRecord::Migration[7.1]
  def change
    create_table :revision_colors do |t|
      t.integer :number
      t.boolean :color
      t.references :revision, polymorphic: true, null: false

      t.timestamps
    end
  end
end
