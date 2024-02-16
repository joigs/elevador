class RenameCarpetas2sToCarpetas < ActiveRecord::Migration[7.1]
  def change
    rename_table :carpetas2s, :carpetas
  end
end
