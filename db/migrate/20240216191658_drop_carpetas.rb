class DropCarpetas < ActiveRecord::Migration[7.1]
  def change
    drop_table :carpetas
  end
end
