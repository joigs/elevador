class Convenio < ApplicationRecord
  belongs_to :empresa


  before_validation :set_month_and_year, if: :fecha_venta_changed?
  private

  def set_month_and_year
    return unless fecha_venta.present?

    self.month = fecha_venta.month
    self.year  = fecha_venta.year
  end

  def empresa_nombre
    empresa&.nombre
  end

end
