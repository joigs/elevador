class Empresa < ApplicationRecord
  has_many :convenios, dependent: :destroy
end
