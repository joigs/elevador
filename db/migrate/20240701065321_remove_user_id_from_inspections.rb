class RemoveUserIdFromInspections < ActiveRecord::Migration[7.1]
  def change
    remove_column :inspections, :user_id, :integer

  end
end
