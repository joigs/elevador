class AddArraysToRevisions < ActiveRecord::Migration[7.1]
  def change
    add_column :revisions, :codes, :string, array: true, default: []
    add_column :revisions, :points, :string, array: true, default: []
    add_column :revisions, :levels, :string, array: true, default: []
  end
end
