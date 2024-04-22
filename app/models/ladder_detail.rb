class LadderDetail < ApplicationRecord

  validates :potencia, non_negative: true, allow_nil: true
  validates :capacidad, non_negative: true, allow_nil: true
  validates :personas, non_negative: true, allow_nil: true
  validates :peldaños, non_negative: true, allow_nil: true
  validates :longitud, non_negative: true, allow_nil: true
  validates :inclinacion, inclusion: { in: 1..89, message: 'debe estar entre 1 y 89 grados' }, allow_nil: true
  validates :ancho, non_negative: true, allow_nil: true
  validates :velocidad, non_negative: true, allow_nil: true
  validates :fabricacion, non_negative: true, allow_nil: true


  belongs_to :item
end
