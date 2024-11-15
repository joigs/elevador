class DropLadderAnothersTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :ladder_anothers
  end
end
