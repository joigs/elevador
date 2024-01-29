class AddDeletedAtToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :deleted_at, :datetime
    add_index :groups, :deleted_at
  end
end