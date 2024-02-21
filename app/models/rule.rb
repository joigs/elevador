class Rule < ApplicationRecord

  include PgSearch::Model

  pg_search_scope :search_full_text,
                  against: [:code, :point],
                  using: {
                    tsearch: { prefix: true }
                  }



  #Permitir que esos sean arrays
  serialize :level, Array,coder: JSON
  serialize :ins_type, Array, coder: JSON

  validates :point, presence: true

  #validan que el array no este vacio
  validate :ins_type_array_presence
  validate :level_array_presence


  before_save :set_code


  belongs_to :ruletype
  has_many :rulesets, dependent: :destroy
  has_many :groups, through: :rulesets
  accepts_nested_attributes_for :rulesets


  scope :ordered_by_code, -> {
    select("rules.*")
      .order(Arel.sql("
      CAST(split_part(code, '.', 1) AS INTEGER),
      CAST(split_part(code, '.', 2) AS INTEGER),
      CASE WHEN split_part(code, '.', 3) = '' THEN 0 ELSE CAST(split_part(code, '.', 3) AS INTEGER) END,
      CASE WHEN split_part(code, '.', 4) = '' THEN 0 ELSE CAST(split_part(code, '.', 4) AS INTEGER) END
    "))
  }


  private

  #calcula el codigo en base al ultimo defecto añadido dentro de la comprobación
  def set_code
    return unless self.code.nil?

    base_number = self.ruletype.gygatype_number.split('.').first + '.' + self.ruletype.gygatype_number.split('.')[1]
    if base_number.start_with?('9')
      base_number = self.ruletype.gygatype_number.split('.')[0..2].join('.')
    end

    max_suffix = Rule.where("code LIKE ?", "#{base_number}.%").map { |rule| rule.code.split('.').last.to_i }.max
    suffix = max_suffix ? max_suffix + 1 : 1
    self.code = "#{base_number}.#{suffix}"
  end


  #valida que el array no este vacio
  def ins_type_array_presence
    errors.add(:"", 'Debe asignar el tipo de defecto') if ins_type.blank? || ins_type.all?(&:blank?)
  end

  def level_array_presence
    errors.add(:"", 'Debe asignar el nivel de importancia') if level.blank? || level.all?(&:blank?)
  end
end
