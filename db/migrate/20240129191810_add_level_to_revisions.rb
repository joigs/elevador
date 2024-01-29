class AddLevelToRevisions < ActiveRecord::Migration[7.1]
  def change
    add_column :revisions, :level, :boolean
  end
end
