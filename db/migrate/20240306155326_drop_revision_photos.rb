class DropRevisionPhotos < ActiveRecord::Migration[7.1]
  def change
    drop_table :revision_photos
  end
end
