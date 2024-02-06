class RemoveForeignKeyFromItems < ActiveRecord::Migration[7.1]
  def change
    remove_reference :items, :minor, foreign_key: true
  end
end
