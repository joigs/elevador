class AddGroupToItem < ActiveRecord::Migration[7.1]
  def change
    add_reference :items, :group, null: false, foreign_key: true
  end
end
