class CreateReports < ActiveRecord::Migration[7.1]
  def change
    create_table :reports do |t|
      t.string :certificado_minvu
      t.date :fecha
      t.string :empresa_anterior
      t.string :ea_rol
      t.string :ea_rut
      t.string :empresa_mantenedora
      t.string :em_rol
      t.string :em_rut
      t.date :vi_co_man_ini
      t.date :vi_co_man_ter
      t.string :nom_tec_man
      t.string :tm_rut
      t.integer :ul_reg_man
      t.date :urm_fecha
      t.references :inspection, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
