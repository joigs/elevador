class User < ApplicationRecord
  has_secure_password
  has_one_attached :signature

  include Minidusen::Filter

  filter :text do |scope, phrases|
    columns = [:username, :real_name, :email]
    scope.where_like(columns => phrases)
  end


  validates :username, presence: true, uniqueness: true,
            length: { in: 3..15 },
            format: {with: /\A[a-z0-9A-Z]+\z/, message: "Solo se permiten letras y numeros"}
  validates :password_digest, length: { minimum: 6 }
  validates :real_name, presence: true
  validates :email, presence: true, uniqueness: true,
            format: { with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, message: "Formato de email invalido" }

  acts_as_paranoid
  has_many :inspections


end
