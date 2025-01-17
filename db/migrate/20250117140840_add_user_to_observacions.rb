class AddUserToObservacions < ActiveRecord::Migration[7.1]
  def change
    add_reference :observacions, :user, null: true, foreign_key: true
  end
end
