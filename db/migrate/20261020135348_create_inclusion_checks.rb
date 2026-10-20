class CreateInclusionChecks < ActiveRecord::Migration[7.1]
  def change
    create_table :inclusion_checks do |t|
      t.references :revision, polymorphic: true, null: false
      t.integer :numero, null: false
      t.boolean :no_implementado, default: false, null: false
      t.boolean :na, default: false, null: false
      t.text :comment
      t.timestamps
    end

    add_index :inclusion_checks, [:revision_type, :revision_id, :numero],
              unique: true, name: "index_inclusion_checks_on_revision_and_numero"
  end
end