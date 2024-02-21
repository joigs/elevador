class Principal < ApplicationRecord

  include PgSearch::Model

  pg_search_scope :search_full_text,
                  against: [:rut, :name, :business_name],
                  using: {
                    tsearch: { prefix: true }
                  }




  validates :name, presence: true, uniqueness: true
  validates :rut, presence: true, uniqueness: true
  validates :business_name, presence: true
  #formato que debe tener un correo electronico
  validates :email, presence: true, uniqueness: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }

  has_many :items
  has_many :inspections
end
