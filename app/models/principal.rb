class Principal < ApplicationRecord

  include PgSearch::Model

  pg_search_scope :search_full_text,
                  against: [:rut, :name, :business_name],
                  using: {
                    tsearch: { prefix: true }
                  }




  validates :name, presence: true, uniqueness: true
  validates :rut, presence: true, uniqueness: true
  validates :business_name, presence: true
  #formato que debe tener un correo electronico
  validates :email, presence: true, uniqueness: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }

  #validar y formatear el rut
  validate :rut_validity
  before_validation :format_rut

  has_many :items
  has_many :inspections




  private

  def format_rut
    clean_rut = rut.delete('.-')
    rut_body = clean_rut[0...-1]
    verifier = clean_rut[-1].upcase

    self.rut = "#{rut_body.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse}-#{verifier}"
  end

  def rut_validity
    clean_rut = rut.delete('.-')
    rut_body = clean_rut[0...-1]
    verifier = clean_rut[-1].upcase

    unless valid_rut?(rut_body, verifier)
      errors.add(:rut, 'is invalid')
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


