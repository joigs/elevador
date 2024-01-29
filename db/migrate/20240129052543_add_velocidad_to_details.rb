class AddVelocidadToDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :details, :velocidad, :string
  end
end
