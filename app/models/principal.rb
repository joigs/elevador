class Principal < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    ["business_name", "cellphone", "contact_email", "contact_name", "created_at", "email", "id", "name", "phone", "place", "rut", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["inspections", "items"]
  end


  validates :name, presence: true, uniqueness: true
  validates :rut, presence: true, uniqueness: true
  #formato que debe tener un correo electronico
  validates :email, allow_blank: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }

  #validar y formatear el rut
  validate :rut_validity, if: :rut?
  before_validation :format_rut, if: :rut?

  has_many :items
  has_many :inspections
  has_many :users, dependent: :nullify



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
      errors.add(:rut, 'es invalido')
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


