class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :identificador, null: false

      t.timestamps
    end
    add_index :items, :identificador, unique: true
  end
end
