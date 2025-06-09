class CreateIvas < ActiveRecord::Migration[7.1]
  def change
    create_table :ivas do |t|
      t.integer :year
      t.integer :month
      t.float :valor

      t.timestamps
    end
    add_index :ivas, %i[year month], unique: true
  end
end
