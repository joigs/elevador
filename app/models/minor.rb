class Minor < ApplicationRecord

  validates :name, presence: true
  validates :email, allow_nil: true, allow_blank: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }


  belongs_to :principal
end
