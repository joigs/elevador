class Detail < ApplicationRecord

  validates :potencia, non_negative: true, allow_nil: true
  validates :capacidad, non_negative: true, allow_nil: true
  validates :personas, non_negative: true, allow_nil: true
  validates :ct_cantidad, non_negative: true, allow_nil: true
  validates :ct_diametro, non_negative: true, allow_nil: true
  validates :paradas, non_negative: true, allow_nil: true
  validates :embarques, non_negative: true, allow_nil: true
  validates :medidas_cintas, non_negative: true, allow_nil: true
  validates :fecha_permiso, date: true
  validates :recepcion, date: true
  validates :velocidad, non_negative: true, allow_nil: true


  validates :porcentaje, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :numero_permiso, non_negative: true, allow_nil: true

  before_validation :format_rut, if: -> { empresa_instaladora_rut.present? }

  validate :rut_validity, if: -> { empresa_instaladora_rut.present? }


  belongs_to :item



  private

  def format_rut
    clean_rut = empresa_instaladora_rut.delete('.-')
    rut_body = clean_rut[0...-1]
    verifier = clean_rut[-1].upcase

    self.empresa_instaladora_rut = "#{rut_body.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}-#{verifier}"
  end

  def rut_validity
    clean_rut = empresa_instaladora_rut.delete('.-')
    rut_body = clean_rut[0...-1]
    verifier = clean_rut[-1].upcase

    unless valid_rut?(rut_body, verifier)
      errors.add(:empresa_instaladora_rut, 'es invalido')
    end
  end

  def valid_rut?(rut_number, rut_dv)
    calculated_dv = calculate_rut_dv(rut_number)
    calculated_dv == rut_dv
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