class Another < ApplicationRecord


  serialize :level, type: Array,coder: JSON
  serialize :ins_type, type: Array, coder: JSON

  validates :point, presence: true

  #validan que el array no este vacio
  validate :ins_type_array_presence
  validate :level_array_presence



  belongs_to :ruletype
  belongs_to :item


  private

  #valida que el array no este vacio
  def ins_type_array_presence
    errors.add(:"", 'Debe asignar el tipo de defecto') if ins_type.blank? || ins_type.all?(&:blank?)
  end

  def level_array_presence
    errors.add(:"", 'Debe asignar el nivel de importancia') if level.blank? || level.all?(&:blank?)
  end

end
