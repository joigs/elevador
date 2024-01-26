class Rule < ApplicationRecord
  #Permitir que esos sean arrays
  serialize :level, Array,coder: JSON
  serialize :ins_type, Array, coder: JSON

  validates :point, presence: true
  validate :ins_type_array_presence
  validate :level_array_presence


  before_save :set_code


  belongs_to :ruletype
  has_many :rulesets, dependent: :destroy
  has_many :groups, through: :rulesets
  accepts_nested_attributes_for :rulesets

  private
  def set_code
    base_number = self.ruletype.gygatype_number.split('.').first + '.' + self.ruletype.gygatype_number.split('.')[1]
    if base_number.start_with?('9')
      base_number = self.ruletype.gygatype_number.split('.')[0..2].join('.')
    end

    suffix = Rule.where("code LIKE ?", "#{base_number}.%").count + 1
    self.code = "#{base_number}.#{suffix}"

  end
  def ins_type_array_presence
    errors.add(:"", 'Debe asignar el tipo de defecto') if ins_type.blank? || ins_type.all?(&:blank?)
  end

  def level_array_presence
    errors.add(:"", 'Debe asignar el nivel de importancia') if level.blank? || level.all?(&:blank?)
  end
end
