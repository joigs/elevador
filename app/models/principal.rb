class Principal < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :rut, presence: true, uniqueness: true
  validates :business_name, presence: true
  #formato que debe tener un correo electronico
  validates :email, presence: true, uniqueness: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }

  has_many :items, through: :minors
  has_many :minors, dependent: :destroy
end
