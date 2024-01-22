class AddUserToInspection < ActiveRecord::Migration[7.1]
  def change
    add_reference :inspections, :user, null: true, foreign_key: true
  end
end
