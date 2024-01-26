class AddMinorRefToItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :items, :minor, null: false, foreign_key: true
  end
end
