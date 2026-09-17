class CreateRevisionComments < ActiveRecord::Migration[7.1]
  def change
    create_table :revision_comments do |t|
      t.references :revision, polymorphic: true, null: false, index: { name: "index_revision_comments_on_revision" }
      t.integer :section
      t.string :code
      t.text :point
      t.string :number
      t.text :comment
      t.timestamps
    end

    add_index :revision_comments, [:revision_type, :revision_id, :section], name: "index_revision_comments_on_revision_and_section"
  end
end