class Minor < ApplicationRecord

  validates :name, presence: true
  #formato que debe tener un correo electronico
  validates :email, allow_nil: true, allow_blank: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }


  belongs_to :principal
  has_many :items, dependent: :destroy
end
