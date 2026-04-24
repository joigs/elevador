class CreatePreferencias < ActiveRecord::Migration[7.1]
  def change
    create_table :preferencias do |t|
      t.string :nombre

      t.timestamps
    end
  end
end
