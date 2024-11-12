class UpdateAnothersAndLadderAnothersForItemAssociation < ActiveRecord::Migration[7.1]
  def change

    remove_column :anothers, :revision_id, :bigint
    remove_column :ladder_anothers, :ladder_revision_id, :bigint

    add_column :anothers, :item_id, :bigint, null: false
    add_column :ladder_anothers, :item_id, :bigint, null: false

    add_index :anothers, :item_id
    add_index :ladder_anothers, :item_id

  end
end
