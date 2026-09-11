class AddTipoUsuarioToPermisos < ActiveRecord::Migration[7.1]
  class MigrationPermiso < ActiveRecord::Base
    self.table_name = "permisos"
  end

  def up
    add_column :permisos, :tipo_usuario, :string, default: "todos", null: false
    MigrationPermiso.reset_column_information
    MigrationPermiso.update_all(tipo_usuario: "interno")

  end

  def down
    remove_column :permisos, :tipo_usuario
  end
end