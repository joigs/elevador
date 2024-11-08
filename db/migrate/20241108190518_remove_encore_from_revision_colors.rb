class RemoveEncoreFromRevisionColors < ActiveRecord::Migration[7.1]
  def change
    remove_column :revision_colors, :encore, :text
  end
end
