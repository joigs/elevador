class Report < ApplicationRecord

  before_save :clear_fields
  validates :ul_reg_man, non_negative: true, allow_nil: true
  validate :validate_ruts
  validates :fecha, date: true
  validates :vi_co_man_ini, date: true
  validates :vi_co_man_ter, date: true
  validates :urm_fecha, date: true
  validates :ending, date: true



  belongs_to :inspection
  belongs_to :item

  private
  def clear_fields
    if cert_ant == 'No'
      self.fecha = nil
      self.empresa_anterior = nil
      self.ea_rol = nil
      self.ea_rut = nil
    end
  end

  def validate_ruts
    ['em_rut', 'ea_rut', 'tm_rut'].each do |rut_column|
      rut_value = send(rut_column)
      next if rut_value.blank? || rut_value == 'S/I'
      unless valid_rut?(rut_value)
        errors.add(rut_column, 'es invalido')
      end
    end
  end

  def valid_rut?(rut)
    clean_rut = rut.delete('.-')
    rut_body = clean_rut[0...-1]
    verifier = clean_rut[-1].upcase

    calculated_dv = calculate_rut_dv(rut_body)
    calculated_dv == verifier
  end

  def calculate_rut_dv(rut_number)
    sum = 0
    multiplier = 2
    rut_number.reverse.each_char do |char|
      sum += char.to_i * multiplier
      multiplier = multiplier < 7 ? multiplier + 1 : 2
    end
    remainder = sum % 11
    remainder == 0 ? '0' : remainder == 1 ? 'K' : (11 - remainder).to_s
  end


end
