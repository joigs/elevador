class AddUniqueConstraintToGroupsNumber < ActiveRecord::Migration[7.1]
  def change
    add_index :groups, :number, unique: true
  end
end
