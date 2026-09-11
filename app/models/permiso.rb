class Permiso < ApplicationRecord
  has_many :user_permisos, dependent: :destroy
  has_many :users, through: :user_permisos

  validates :nombre, presence: true, uniqueness: true
  validates :descripcion, presence: true
  TIPOS_USUARIO = {
    "todos"   => "Todos los usuarios",
    "interno" => "Solo usuarios internos",
    "cliente" => "Solo usuarios de tipo cliente"
  }.freeze

  EMPRESA_ADMIN = "empresa_admin".freeze
  RECIBE_CORREO = "recibe_correo".freeze

  validates :tipo_usuario, inclusion: { in: TIPOS_USUARIO.keys }

  scope :para_cliente, -> { where(tipo_usuario: %w[todos cliente]) }
  scope :para_interno, -> { where(tipo_usuario: %w[todos interno]) }

  def self.disponibles_para(user)
    user.cliente? ? para_cliente : para_interno
  end


end
