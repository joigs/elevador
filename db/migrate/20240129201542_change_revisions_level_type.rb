class ChangeRevisionsLevelType < ActiveRecord::Migration[7.1]
  def change
    change_column :revisions, :level, :string
  end
end
