class NotificationsFacturacion < ApplicationRecord
  belongs_to :notification
  belongs_to :facturacion

  validates :notification_id, uniqueness: { scope: :facturacion_id }
end
