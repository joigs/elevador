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
  has_many :sucursal_users, dependent: :destroy
  has_many :sucursals, through: :sucursal_users

  def item_ids_visibles
    ultimos = Inspection.where("number > 0")
                        .where(principal_id: principal_ids)
                        .group(:item_id)
                        .maximum(:number)
                        .values

    Inspection.where(number: ultimos, sucursal_id: sucursal_ids).pluck(:item_id)
  end

  def sucursales_gestionables_en(principal)
    return principal.sucursals unless cliente?
    return Sucursal.none unless empresa_admin?

    sucursals.where(principal_id: principal.id)
  end

  def sucursales_asignables_para(otro)
    base =
      if !cliente?
        Sucursal.where(principal_id: otro.principal_ids)
      elsif empresa_admin?
        sucursals.joins(:principal).where(principals: { activo: true })
      else
        Sucursal.none
      end

    base.joins(:principal).includes(:principal).order("principals.name ASC, sucursals.id ASC")
  end

  def puede_gestionar_sucursales_de?(otro)
    return false if otro.nil? || !otro.cliente?
    return true if admin? || puede_gestionar_permisos_de?(otro)
    return false if otro == self

    empresa_admin? && (otro.sucursal_ids & sucursal_ids).any?
  end

  def usuarios_gestionables_en(principal)
    return principal.users if admin?
    return User.none unless empresa_admin?

    mis_sucursales = sucursals.where(principal_id: principal.id).select(:id)
    principal.users.joins(:sucursal_users).where(sucursal_users: { sucursal_id: mis_sucursales }).distinct
  end

  def sincronizar_empresas_desde_sucursales!
    empresas = SucursalUser.joins(:sucursal).where(user_id: id).distinct.pluck("sucursals.principal_id")
    PrincipalUser.where(user_id: id).where.not(principal_id: empresas).destroy_all
    empresas.each { |principal_id| PrincipalUser.find_or_create_by!(user_id: id, principal_id: principal_id) }
    reload
  end

  def sincronizar_sucursales_con_empresas!
    empresas = PrincipalUser.where(user_id: id).pluck(:principal_id)
    SucursalUser.joins(:sucursal).where(user_id: id).where.not(sucursals: { principal_id: empresas }).destroy_all

    con_sucursal = SucursalUser.joins(:sucursal).where(user_id: id).distinct.pluck("sucursals.principal_id")
    (empresas - con_sucursal).each do |principal_id|
      Sucursal.where(principal_id: principal_id).pluck(:id).each do |sucursal_id|
        SucursalUser.find_or_create_by!(user_id: id, sucursal_id: sucursal_id)
      end
    end

    reload
  end

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

    case record
    when Inspection
      record.sucursal_id.present? && sucursal_ids.include?(record.sucursal_id)
    when Item
      ultima = record.inspections.where("number > 0").order(number: :desc).first
      ultima.present? && ultima.sucursal_id.present? && sucursal_ids.include?(ultima.sucursal_id)
    when Sucursal
      sucursal_ids.include?(record.id)
    else
      objetivo = principal_id_de(record)
      objetivo.present? && principal_ids.include?(objetivo)
    end
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
