class User < ApplicationRecord
  has_secure_password

  acts_as_paranoid

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
    # List of associations you want to be searchable
    [
      "inspections",  # Assuming inspections are related records that could be relevant for searches
    ]
  end

  validates :username, presence: true, uniqueness: true,
            length: { in: 3..15 },
            format: {with: /\A[a-z0-9A-Z]+\z/, message: "Solo se permiten letras y numeros"}
  validates :password_digest, length: { minimum: 6 }
  validates :real_name, presence: true
  validates :email, allow_blank: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }




  has_many :inspection_users, dependent: :destroy
  has_many :inspections, through: :inspection_users

  has_many :user_permisos, dependent: :destroy
  has_many :permisos, through: :user_permisos
  has_many :observacions, dependent: :nullify


  belongs_to :principal, optional: true, touch: false


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



  scope :con_permiso_inspeccionar, -> {
    joins(:permisos).where(permisos: { nombre: 'inspeccionar' })
  }

  scope :admin_false_o_inspeccionar, -> {
    left_joins(:permisos).where(admin: false).or(
      left_joins(:permisos).where(permisos: { nombre: 'inspeccionar' })
    )
  }


end
