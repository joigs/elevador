class ChangeRecepcionTypeInLadderDetailsAndDetails < ActiveRecord::Migration[7.1]
  def change
    change_column :ladder_details, :recepcion, :date
    change_column :details, :recepcion, :date
  end
end
