class Report < ApplicationRecord

  before_save :clear_fields
  validates :ul_reg_man, non_negative: true, allow_nil: true

  belongs_to :inspection
  belongs_to :item

  private
  #Si no hay certificado anterior, se limpian los campos
  def clear_fields
    if cert_ant == 'No'
      self.fecha = nil
      self.empresa_anterior = nil
      self.ea_rol = nil
      self.ea_rut = nil
    end
  end
end
