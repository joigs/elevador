class Notification < ApplicationRecord
  has_many :notifications_facturacions, dependent: :destroy
  has_many :facturacions, through: :notifications_facturacions

  enum notification_type: {
    solicitud_pendiente: 1,
    entrega_pendiente: 2,
    factura_pendiente: 3,
    inspeccion_proxima: 4,
    inspeccion_vencida: 5
  }

  validates :title, presence: true
  validates :text, presence: true
  validates :notification_type, presence: true
end


=begin


Notification.create!(
  title: "Solicitudes de Cotización Pendientes",
  text: "Existen solicitudes de cotización que aún no han sido atendidas.",
  notification_type: :solicitud_pendiente
)


Notification.create!(
  title: "Entregas a Clientes Pendientes",
  text: "Existen cotizaciones emitidas que aún no han sido entregadas.",
  notification_type: :entrega_pendiente
)



Notification.create!(
  title: "Facturas Pendientes",
  text: "Existen órdenes de compra aceptadas que aún no tienen factura emitida.",
  notification_type: :factura_pendiente
)




Notification.create!(
  title: "Inspección vencerá dentro de 2 meses",
  text: "Existen [[N]] inspecciones que vencerán en los próximos 2 meses.",
  notification_type: :inspeccion_proxima
)




Notification.create!(
  title: "Inspecciones vencidas",
  text: "Existen [[N]] inspecciones que ya vencieron.",
  notification_type: :inspeccion_vencida
)





=end
