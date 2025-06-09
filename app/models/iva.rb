class Iva < ApplicationRecord
  validates :year,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1900 }

  validates :month,
            presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 12 },
            uniqueness: { scope: :year }

  validates :valor,
            presence: true,
            numericality: true

  scope :chronological, -> { order(year: :asc, month: :asc) }
end
