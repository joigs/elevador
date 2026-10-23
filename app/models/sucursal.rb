class Sucursal < ApplicationRecord
  belongs_to :principal
  has_many :inspections
  has_many :sucursal_users, dependent: :destroy
  has_many :users, through: :sucursal_users

  validates :nombre, presence: true, uniqueness: { scope: :principal_id }
  validates :contact_email, allow_blank: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }

  before_destroy :verificar_eliminable, prepend: true
  def detalle_contacto
    [place, contact_name, contact_email, cellphone].map(&:presence).compact.join(" · ").presence || "Sin datos de contacto"
  end

  private

  def verificar_eliminable
    return if destroyed_by_association

    if inspections.exists?
      errors.add(:base, "No se puede eliminar: la sucursal tiene inspecciones asociadas")
      throw :abort
    end

    if principal.sucursals.count <= 1
      errors.add(:base, "La empresa debe tener al menos una sucursal")
      throw :abort
    end
  end
end