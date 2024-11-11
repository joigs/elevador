class CreateLadderAnothers < ActiveRecord::Migration[7.1]
  def change
    create_table :ladder_anothers, charset: "utf8mb4", collation: "utf8mb4_general_ci" do |t|
      t.text :point, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :code
      t.string :level
      t.bigint :ladder_revision_id, null: false
      t.string :section
      t.string :priority
      t.string :number

      t.index :ladder_revision_id, name: "index_ladder_anothers_on_ladder_revision_id"
    end
  end
end
