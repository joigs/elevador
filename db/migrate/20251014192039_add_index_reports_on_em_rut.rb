class AddIndexReportsOnEmRut < ActiveRecord::Migration[7.1]
  def change
    add_index :reports, :em_rut

  end
end
