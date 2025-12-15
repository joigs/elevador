class AddSecondaryTypeToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :secondary_type, :string, null: true
  end
end
