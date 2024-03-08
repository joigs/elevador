class CreateRevisionPhotospoli < ActiveRecord::Migration[7.1]
  def change
    create_table :revision_photos do |t|
      t.string :code
      t.references :revision, polymorphic: true, null: false

      t.timestamps
    end
  end
end
