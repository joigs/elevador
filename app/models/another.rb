class Another < ApplicationRecord
  serialize :level, type: Array, coder: JSON
  serialize :ins_type, type: Array, coder: JSON

  validates :point, presence: true

  validate :ins_type_array_presence
  validate :level_array_presence

  belongs_to :ruletype
  belongs_to :item

  private

  def ins_type_array_presence
    if ins_type.blank? || ins_type.all?(&:blank?)
      errors.add(:ins_type, 'Debe asignar el tipo de defecto')
    end
  end

  def level_array_presence
    if level.blank? || level.all?(&:blank?)
      errors.add(:level, 'Debe asignar el nivel de importancia')
    end
  end
end
