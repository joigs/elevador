class Permiso < ApplicationRecord
  has_many :user_permisos, dependent: :destroy
  has_many :users, through: :user_permisos

  validates :nombre, presence: true, uniqueness: true
  validates :descripcion, presence: true



end
