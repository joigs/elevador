class AddCommentToRevisionNulls < ActiveRecord::Migration[7.1]
  def change
    add_column :revision_nulls, :comment, :text
  end
end
