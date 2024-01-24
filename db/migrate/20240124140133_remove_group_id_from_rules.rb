class RemoveGroupIdFromRules < ActiveRecord::Migration[7.1]
  def change
    remove_column :rules, :group_id
  end
end
