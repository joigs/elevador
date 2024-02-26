class ChangeFailToEnumInRevisions < ActiveRecord::Migration[7.1]
  def up
    change_column :revisions, :fail, :string
  end


end
