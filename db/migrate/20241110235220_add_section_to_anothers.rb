class AddSectionToAnothers < ActiveRecord::Migration[7.1]
  def change
    add_column :anothers, :section, :string
  end
end
