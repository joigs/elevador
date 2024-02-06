class AddRevisionToFlaws < ActiveRecord::Migration[7.1]
  def change
    add_reference :points, :revision, null: false, foreign_key: true
  end
end
