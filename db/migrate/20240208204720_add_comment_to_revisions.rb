class AddCommentToRevisions < ActiveRecord::Migration[7.1]
  def change
    add_column :revisions, :comment, :string, array: true, default: []
  end
end
