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
  has_many :principal_users, dependent: :destroy
  has_many :users, through: :principal_users

  before_destroy :eliminar_usuarios_exclusivos, prepend: true

  scope :activas, -> { where(activo: true) }
  def activar!
    update!(activo: true)
  end

  def desactivar!
    update!(activo: false)
  end

  def alertas
    hoy       = Time.zone.today
    dos_meses = (hoy + 2.months).end_of_month

    ultimas_ids = inspections
                    .where("number > 0")
                    .select(:id, :item_id, :number)
                    .order(:item_id, number: :desc)
                    .group_by(&:item_id)
                    .values
                    .map { |inspecciones| inspecciones.first.id }

    base = Inspection.where(id: ultimas_ids, ignorar: false)

    definiciones = {
      "proximas" => {
        titulo: "Certificaciones por vencer",
        texto: "con la certificación por vencer en los próximos 2 meses.",
        estilo: "amber",
        scope: base.joins(:report)
                   .where(state: "Cerrado", result: ["Aprobado", "Vencido (Aprobado)"])
                   .where("reports.ending >= ? AND reports.ending <= ?", hoy, dos_meses)
      },
      "rechazadas_proximas" => {
        titulo: "Rechazadas con reinspección próxima",
        texto: "rechazados con fecha límite en los próximos 2 meses.",
        estilo: "orange",
        scope: base.joins(:report)
                   .where(state: "Cerrado", result: ["Rechazado", "Vencido (Rechazado)"])
                   .where("reports.ending >= ? AND reports.ending <= ?", hoy, dos_meses)
      },
      "vencidas_aprobadas" => {
        titulo: "Certificaciones vencidas",
        texto: "con la certificación aprobada ya vencida.",
        estilo: "rose",
        scope: base.joins(:report)
                   .where(state: "Cerrado", result: ["Aprobado", "Vencido (Aprobado)"])
                   .where("reports.ending < ?", hoy)
      },
      "vencidas_rechazadas" => {
        titulo: "Certificaciones vencidas (rechazadas)",
        texto: "rechazados con el plazo ya vencido.",
        estilo: "rose_fuerte",
        scope: base.joins(:report)
                   .where(state: "Cerrado", result: ["Rechazado", "Vencido (Rechazado)"])
                   .where("reports.ending < ?", hoy)
      }
    }

    definiciones.each_with_object({}) do |(clave, datos), acumulador|
      ids = datos[:scope].pluck(:id)
      next if ids.empty?

      n = ids.size
      sujeto = n == 1 ? "1 activo" : "#{n} activos"

      acumulador[clave] = {
        titulo: datos[:titulo],
        texto:  "#{sujeto} #{datos[:texto]}",
        estilo: datos[:estilo],
        ids:    ids,
        count:  n
      }
    end
  end

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

  def eliminar_usuarios_exclusivos
    users.includes(:principal_users).each do |user|
      user.destroy if user.principal_users.size == 1
    end
  end
end


