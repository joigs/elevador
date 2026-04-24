class Preferencia < ApplicationRecord
  has_many :user_preferencias, dependent: :destroy
  has_many :users, through: :user_preferencias
end