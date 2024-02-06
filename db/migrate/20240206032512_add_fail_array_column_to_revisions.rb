class AddFailArrayColumnToRevisions < ActiveRecord::Migration[7.1]
  def change
    add_column :revisions, :fail, :boolean, array: true, default: []
  end
end
