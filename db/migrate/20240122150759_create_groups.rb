class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.integer :number , null: false

      t.timestamps
    end
  end
end
