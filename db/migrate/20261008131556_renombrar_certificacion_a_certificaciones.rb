class RenombrarCertificacionACertificaciones < ActiveRecord::Migration[7.1]
  def up
    ActiveStorage::Attachment
      .where(record_type: "Inspection", name: "certificacion")
      .update_all(name: "certificaciones")
  end

  def down
    ActiveStorage::Attachment
      .where(record_type: "Inspection", name: "certificaciones")
      .update_all(name: "certificacion")
  end
end