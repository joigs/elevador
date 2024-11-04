class AddEncoreToRevisionColors < ActiveRecord::Migration[7.1]
  def change
    add_column :revision_colors, :encore, :text
  end
end
