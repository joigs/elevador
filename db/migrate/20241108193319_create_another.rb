class CreateAnother < ActiveRecord::Migration[7.1]
  def change
    create_table :anothers, charset: "utf8mb4", collation: "utf8mb4_general_ci" do |t|
      t.text :point, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.bigint :ruletype_id, null: false
      t.string :code
      t.string :level
      t.string :ins_type
      t.index :ruletype_id, name: "index_anothers_on_ruletype_id"
    end
  end
end
