class Ruletype < ApplicationRecord
  validates :rtype, presence: true, uniqueness: true
  has_many :rules, dependent: :destroy
end
