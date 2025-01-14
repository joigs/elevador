class Facturacion < ApplicationRecord
  has_many :observacions, dependent: :destroy

  enum resultado: { "": 0, "En espera": 1, "Aceptado": 2, "Rechazado": 3 }

  after_initialize do
    self.solicitud ||= Date.today
  end

end
