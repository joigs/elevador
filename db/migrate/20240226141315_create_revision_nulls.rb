class CreateRevisionNulls < ActiveRecord::Migration[7.1]
  def change
    create_table :revision_nulls do |t|
      t.string :code
      t.string :point
      t.references :revision, null: false, foreign_key: true

      t.timestamps
    end
  end
end
