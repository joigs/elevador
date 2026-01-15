class MakeRuletypeIdNullableInAnothers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :anothers, :ruletype_id, true

  end
end
