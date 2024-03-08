class CreateRevisionNullsPoli < ActiveRecord::Migration[7.1]
  def change
    create_table :revision_nulls do |t|
      t.string :point
      t.references :revision, polymorphic: true, index: true

      t.timestamps
    end
  end
end
