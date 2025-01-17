class Facturacion < ApplicationRecord
  has_many :observacions, dependent: :destroy

  # Define tus cinco archivos ActiveStorage (uno_attached)
  has_one_attached :solicitud_file
  has_one_attached :cotizacion_doc_file
  has_one_attached :cotizacion_pdf_file
  has_one_attached :orden_compra_file
  has_one_attached :facturacion_file

  enum resultado: { no: 0, "En espera": 1, "Aceptado": 2, "Rechazado": 3 }

  # Validaciones obligatorias
  validates :number, presence: true
  validates :name, presence: true
  validates :solicitud_file, presence: true

  validates :cotizacion_doc_file, presence: true, if: -> { emicion.present? }
  validates :cotizacion_pdf_file, presence: true, if: -> { emicion.present? }
  after_initialize do
    self.solicitud ||= Date.today
  end
end
