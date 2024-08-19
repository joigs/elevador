class ChangeVelocidadToFloatInDetails < ActiveRecord::Migration[7.1]
  def change
    change_column :details, :velocidad, :float
  end
end
