class ChangeRevisionsNumberNullable < ActiveRecord::Migration[7.1]
  def change
    change_column :revisions, :number, :integer, null: true
  end
end
