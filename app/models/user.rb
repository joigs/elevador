class User < ApplicationRecord
  has_secure_password

  acts_as_paranoid
  has_one_attached :signature


  def self.ransackable_attributes(auth_object = nil)
    [
      "username",
      "real_name",
      "email",
      "profesion",
      "created_at",
      "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "inspections",
    ]
  end

  validates :username, presence: true, uniqueness: true,
            length: { in: 3..15 },
            format: {with: /\A[a-z0-9A-Z]+\z/, message: "Solo se permiten letras y numeros"}
  validates :password, length: { minimum: 6, message: "debe tener al menos 6 caracteres" }, allow_nil: true
  validates :password_digest, length: { minimum: 6 }
  validates :real_name, presence: true
  validates :email, allow_blank: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }




  has_many :inspection_users, dependent: :destroy
  has_many :inspections, through: :inspection_users

  has_many :user_permisos, dependent: :destroy
  has_many :permisos, through: :user_permisos
  has_many :observacions, dependent: :nullify

  has_many :user_preferencias, dependent: :destroy
  has_many :preferencias, through: :user_preferencias


  belongs_to :principal, optional: true, touch: false
  belongs_to :favorito_admin, class_name: 'User', optional: true
  has_many :usuarios_que_lo_prefieren, class_name: 'User', foreign_key: 'favorito_admin_id', dependent: :nullify

  def solicitar
    permisos.exists?(nombre: 'solicitar')
  end

  def cotizar
    permisos.exists?(nombre: 'cotizar')
  end

  def certificar
    permisos.exists?(nombre: 'certificar')
  end

  def inspeccionar
    permisos.exists?(nombre: 'inspeccionar')
  end

  def crear
    permisos.exists?(nombre: 'crear')
  end

  def mini_solicitar
    permisos.exists?(nombre: 'mini_solicitar')
  end

  def only_see
    permisos.exists?(nombre: 'only_see')
  end

  has_many :principal_users, dependent: :destroy
  has_many :principals, through: :principal_users

  def cliente?
    empresa.present?
  end

  def empresa_admin?
    cliente? && permisos.exists?(nombre: "empresa_admin")
  end

  def recibe_correo?
    permisos.exists?(nombre: "recibe_correo")
  end

  def empresas_activas
    principals.where(activo: true)
  end

  def empresa_unica
    empresas_activas.first if empresas_activas.count == 1
  end

  def empresas_gestionables
    return Principal.where(activo: true).order(:name) if admin?
    return Principal.none unless empresa_admin?

    empresas_activas.order(:name)
  end


  def gestionar_permisos_clientes
    permisos.exists?(nombre: 'gestionar_permisos_clientes')
  end

  def puede_gestionar_permisos_de?(otro)
    return false if otro.nil? || otro.relleno
    return true if super?

    !cliente? && gestionar_permisos_clientes && otro.cliente?
  end


  scope :con_permiso_inspeccionar, -> {
    joins(:permisos).where(permisos: { nombre: 'inspeccionar' })
  }

  scope :admin_false_o_inspeccionar, -> {
    left_joins(:permisos)
      .where(admin: false)
      .or(left_joins(:permisos).where(permisos: { nombre: 'inspeccionar' }))
      .where.not(
      id: User.joins(:permisos).where(permisos: { nombre: 'only_see' })
    )
      .distinct
  }



  def empresa_de?(record)
    return false if empresa.blank?

    objetivo = principal_id_de(record)
    return false if objetivo.blank?

    principal_ids.include?(objetivo)
  end


  scope :activos, -> { where(activo: true) }

  def puede_iniciar_sesion?
    return false unless activo?
    return true unless cliente?

    empresas_activas.exists?
  end
  generates_token_for :password_reset, expires_in: 30.minutes do
    password_salt&.last(10)
  end


  private

  def principal_id_de(record)
    case record
    when Principal   then record.id
    when Inspection  then record.principal_id || record.item&.principal_id
    when Item        then record.principal_id
    else                  record.try(:principal_id)
    end
  end


end
