class Facturacion < ApplicationRecord
  has_many :observacions, dependent: :destroy
  has_many :notifications_facturacions, dependent: :destroy
  has_many :notifications, through: :notifications_facturacions
  has_many :inspections

  has_one_attached :solicitud_file
  has_one_attached :cotizacion_doc_file
  has_one_attached :cotizacion_pdf_file
  has_one_attached :orden_compra_file
  has_one_attached :facturacion_file

  enum resultado: { "N/A": 0, "En espera": 1, "Aceptado": 2, "Rechazado": 3, "Relleno": 4 }

  validates :number, presence: true
  validates :name, presence: true
  validates :solicitud_file, presence: true

  validates :cotizacion_pdf_file, presence: true, if: -> { emicion.present? }



  after_initialize do
    self.solicitud ||= Date.today
  end


  validate :valid_file_types

  def fecha_inspeccion
    if inspections.exists?(rerun: false)
      inspections.where(rerun: false).maximum(:ins_date)
    else
      inspections.maximum(:ins_date)
    end
  end


  # app/models/tu_modelo.rb
  def empresa
    # 1) IDs de principal sin duplicados y sin nil
    ids = inspections.distinct.pluck(:principal_id).compact

    # 2) Si no hay inspecciones, devolvemos la provisional (si existe) o nil
    return empresa_provisional.presence if ids.empty?

    # 3) Si hay más de un principal distinto ⇒ error de datos
    return "Error-empresa" if ids.many?

    # 4) Una sola inspección válida ⇒ buscar el nombre
    Principal.find_by(id: ids.first)&.name || "Error-empresa"
  end



  def inspecciones_con_resultado_count
    inspections.con_resultado.count
  end

  def inspecciones_total
    inspections.count 
  end

  def inspecciones_total_no_rerun
    inspections.where(rerun: false).count
  end










  private

  def valid_file_types
    validate_file_type(solicitud_file, %w[application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet], "Excel")
    validate_file_type(cotizacion_doc_file, %w[application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document], "Word")
    validate_file_type(cotizacion_pdf_file, %w[application/pdf], "PDF")
    validate_file_type(orden_compra_file, %w[application/pdf image/png image/jpeg image/jpg], "PDF, PNG, JPG, o JPEG")
    validate_file_type(facturacion_file, %w[application/pdf], "PDF")
  end

  def validate_file_type(file, allowed_types, type_name)
    if file.attached? && !file.content_type.in?(allowed_types)
      errors.add(file.name.to_sym, "debe ser un archivo #{type_name}")
    end
  end

end
