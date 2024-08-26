class ChangeSectionAndNumberInRevisionColors < ActiveRecord::Migration[7.1]
  def change
    change_column :revision_colors, :section, :integer
    change_column :revision_colors, :number, :string
  end
end
