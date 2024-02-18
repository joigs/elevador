class ChangeColumnsToArrayInBags < ActiveRecord::Migration[7.1]
  def change
    change_column :bags, :number, :integer, array: true, default: [], using: 'ARRAY[number]::INTEGER[]'
    change_column :bags, :cumple, :string, array: true, default: [], using: 'ARRAY[cumple]::TEXT[]'
    change_column :bags, :falla, :boolean, array: true, default: [], using: 'ARRAY[falla]::BOOLEAN[]'
    change_column :bags, :comentario, :string, array: true, default: [], using: 'ARRAY[comentario]::TEXT[]'
  end
end
