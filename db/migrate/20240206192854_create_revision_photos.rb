  class CreateRevisionPhotos < ActiveRecord::Migration[7.1]
  def change
    create_table :revision_photos do |t|
      t.references :revision, null: false, foreign_key: true
      t.string :code
      t.timestamps
    end
  end
end
