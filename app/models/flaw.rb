class Flaw < ApplicationRecord

  validates :point , presence: true
  validates :code , presence: true
  validates :level , presence: true

  belongs_to :revision
end