class ChangeNameColumnNullConstraint < ActiveRecord::Migration[7.1]
  def change
    change_column_null :groups, :name, false
  end
end
