class CreatePlatRevisionRulesPlats < ActiveRecord::Migration[7.1]
  def change
    create_table :plat_revision_rules_plats do |t|
      t.references :plat_revision, null: false, foreign_key: true
      t.references :rules_plat,    null: false, foreign_key: true
      t.string     :level,         null: false

      t.timestamps
    end

    add_index :plat_revision_rules_plats,
              [:plat_revision_id, :rules_plat_id],
              unique: true,
              name: "index_plat_revision_rules_plats_on_revision_and_rule"
  end
end
